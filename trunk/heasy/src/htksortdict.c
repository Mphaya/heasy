// Author: Neil Kleynhans
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define BUF_SIZE 512

// Determine the number of dictionary entries and total size in bytes
static size_t HowManyEntries(FILE *fHandle, size_t *bytes)
{
    size_t entryCount = 0;
    char buf[BUF_SIZE], *s;

    *bytes = 0;
    while((s = fgets(buf, BUF_SIZE, fHandle))) {
        if(s) {
            entryCount++;
            *bytes += strlen(s);
        }
    }
    rewind(fHandle);

    return entryCount;
}

// Replace many whitespaces with a single
static  char * TrimSpace(char *dst)
{
    const char *src = dst;
    int tocopy = 1;
    char c;

    while((c = *src++)) {
        if(tocopy)
            *dst++ = c;
        tocopy = (c != ' ') || (*src != ' ');
    }
    *dst = '\0';

    return dst;
}

// Replace character with another
static char * ReplaceChar(char *dst, char old, char new)
{
    const char *src = dst;
    char c;

    while((c = *src++)) {
        if(c == old) c = new;
        *dst++ = c;
     }
    *dst = '\0';

    return dst;
}

// Load dictionry entries
// Split entry into: Word, Out Symbol (optional), Probability (optional), Pronunciation
// Place entries into char buffer
// Return Index of entries
static void LoadEntries(FILE *fHandle, char * ent, char *ePtr[])
{
    size_t nProcessed;
    char *s, *c, *d, *e, buf[BUF_SIZE], tmp[BUF_SIZE], *ndx;
    char word[BUF_SIZE], oSym[BUF_SIZE], pProb[BUF_SIZE], pron[BUF_SIZE];
    float pVal;

    nProcessed = 0;
    ndx = ent;

    while((s = fgets(buf, BUF_SIZE, fHandle))) {
        if(!s) break;
        strcpy(tmp, buf);
        ReplaceChar(tmp, '\t', ' '); // replace tab
        TrimSpace(tmp); // trim excessive whitespace
        ReplaceChar(tmp, '\n', '\0'); // replace trailing newline with string terminating char

        // Zero out string buffers
        word[0] = '\0';
        oSym[0] = '\0';
        pProb[0] = '\0';
        pron[0] = '\0';

        // Copy word
        s = &word[0];
        c = tmp;
        while(*c != ' ') *s++ = *c++;
        *s = '\0';
        c++;

        // Check if out symbol present and copy
        d = c;
        c = strstr(c, "[");
        if(c) {
            s = &oSym[0];
            while(*c != ' ') *s++ = *c++;
            *s = '\0';
            c++;
        } else {
            c = d;
        }

        // Check if float probablity is present and copy
        d = c;
        pVal = strtof(c, &e);
        if(pVal != 0.0) {
            c = d;
            s = &pProb[0];
            while(*c != ' ') *s++ = *c++;
            *s = '\0';
             c++;
        } else {
            c = d;
        }

        // Copy pronunciation
        s = &pron[0];
        while(*c != '\0') *s++ = *c++;
        *s = '\0';

        // Write string to buffer in internal format
        s = ndx;
        ePtr[nProcessed] = ndx;
        s += sprintf(s, "%s\t%s", word, pron);
        if(strlen(oSym) > 0)
            s += sprintf(s, "\t%s", oSym);
        if(strlen(pProb) > 0)
            s += sprintf(s, "\t%s", pProb);

        ndx = s+1;
        nProcessed++;
    }
}

// qsort string comparision function
static int CmpEntries(const void *p1, const void *p2)
{
    return strcmp(* (char * const *) p1, * (char * const *) p2);
}

// Write entries to output file
// Break up internal entry format and build entry into HTK format
static void WriteDict(FILE *fout, char *index[], size_t nProns)
{
    size_t nProc;
    char *s, *c;
    char word[BUF_SIZE], oSym[BUF_SIZE], pProb[BUF_SIZE], pron[BUF_SIZE];

    for(nProc = 0; nProc < nProns; nProc++) {
        // Zero out buffers
        word[0] = '\0';
        oSym[0] = '\0';
        pProb[0] = '\0';
        pron[0] = '\0';

        // Move to word position in string
        s = index[nProc];
        c = word;
        // Check if word starts with ' or "
        if((*s == '\'') || (*s == '"'))
            *c++ = '\\';
        // Copy ouf word
        while(*s != '\t') *c++ = *s++;
        *c='\0';

        // Move to pronunciation
        c = pron;
        s++;
        while((*s != '\t') && (*s != '\0')) *c++ = *s++;
        *c='\0';

        // Is there more data - out symbol
        if(*s == '\t') {
            s++;
            c = oSym;
            while((*s != '\t') && (*s != '\0')) *c++ = *s++;
            *c='\0';

            // Is there a probability
            if(*s == '\t') {
                s++;
                c = pProb;
                while(*s != '\0') *c++ = *s++;
                *c='\0';
            }
        }

        // Write to file
        fprintf(fout, "%s\t", word);
        if(strlen(oSym) > 0)
            fprintf(fout, "%s ", oSym);
        if(strlen(pProb) > 0)
            fprintf(fout, "%s ", pProb);
        fprintf(fout, "%s\n", pron);
    }

}

int main(int argc, char *argv[])
{
    FILE *fin, *fout;
    char src[FILENAME_MAX], dest[FILENAME_MAX], *entries, **ePtr;
    size_t nProns, szFile, k;

    if(argc != 3) {
        fprintf(stderr, "%s: in_unsorted_dict out_sorted_dict\n", argv[0]);
        exit(1);
    }

    strcpy(src, argv[1]);
    strcpy(dest, argv[2]);

    fin = fopen(src, "r");
    if(!fin) {
        fprintf(stderr, "ERROR (%s): Cannot open file %s", argv[0], src);
        exit(1);
    }

    fout = fopen(dest, "w");
    if(!fout) {
        fprintf(stderr, "ERROR (%s): Cannot open file %s", argv[0], dest);
        exit(1);
    }

    nProns = HowManyEntries(fin, &szFile);
    if(nProns == 0) {
        fprintf(stderr, "ERROR (%s): Dictionary (%s) has no entries!", argv[0], src);
        exit(1);
    }

    if(szFile == 0) {
        fprintf(stderr, "ERROR (%s): Dictionary (%s) is empty!", argv[0], src);
        exit(1);
    }

    entries = (char *)malloc(sizeof(char)*szFile);
    ePtr = calloc(nProns, sizeof(char *));

    LoadEntries(fin, entries, ePtr);
    qsort(&ePtr[0], nProns, sizeof(char *), CmpEntries);
    WriteDict(fout, ePtr, nProns);

    free(entries);
    free(ePtr);
    fclose(fin);
    fclose(fout);

    return 0;
}

