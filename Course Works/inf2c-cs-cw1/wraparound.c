/***********************************************************************
* File       : <wraparound.c>
*
* Author     : <M.R. Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/19
*
***********************************************************************/
// ==========================================================================
// 2D String Finder
// ==========================================================================
// Finds the matching words from dictionary in the 2D grid, including wrap-around

// Inf2C-CS Coursework 1. Task 6
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2019

#include <stdio.h>

// maximum size of each dimension
#define MAX_DIM_SIZE 32
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 1000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 10

int read_char() { return getchar(); }
int read_int()
{
  int i;
  scanf("%i", &i);
  return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }
void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
const char dictionary_file_name[] = "dictionary.txt";
// grid file name
const char grid_file_name[] = "2dgrid.txt";
// content of grid file
char grid[(MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE + 1 /* for \0 */ ];
// content of dictionary file 
char dictionary[MAX_DICTIONARY_WORDS * (MAX_WORD_SIZE + 1 /* for \n */ ) + 1 /* for \0 */ ];
///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////Put your global variables/functions here///////////////////////

// starting index of each word in the dictionary
int dictionary_idx[MAX_DICTIONARY_WORDS];
// number of words in the dictionary
int dict_num_words = 0;
int linewidth = 0;
int rows = 0;
int size = 0;

// function to print found word
void print_word(char *word)
{
  while(*word != '\n' && *word != '\0') {
    print_char(*word);
    word++;
  }
}

// function to see if the string contains the (\n terminated) word
// to check horizontally inc should be 1
// to check vertically inc should be linewidth
// to check diagonally inc should be linewidth + 1 ( need check for end of lines)
int contain(char *string, char *word, int inc, int stepback)
{
  while (1) {
    if (*string == '\n') {
      if (stepback){
        string -= stepback;
      } else {
        string -= (linewidth + 1) * ((string-grid)/linewidth);
      }
    }

    if ((string - grid) > (size - 1)){
      if (stepback){
        string -= stepback;
      } else {
        string -= (linewidth + 1) * ((string-grid)/linewidth);
      }
    } 

    if (*string != *word){
      return (*word == '\n');
    } 
         
    string += inc;

    if ((string - grid) > (MAX_DIM_SIZE + 1 /* for \n */ ) * MAX_DIM_SIZE) {// if the current index within the grid is greater than the max index of the grid,
      printf("out of bounds \n"); //for debugging c (not needed in MIPS)
      if (stepback){
        string -= stepback;
      } else {
        string -= (linewidth + 1) * ((string-grid)/linewidth);
      }
      //return(*word == '\n'); //check if at the end of the word, if so, its a match, if not it's not
    }

    word++;
  }
}

  // this functions finds the first match in the grid
void strfind()
{
  int found = 0;
  int idx = 0;
  int grid_idx = 0;
  char *word;
  while (grid[grid_idx] != '\0') {
    for(idx = 0; idx < dict_num_words; idx ++) {
      word = dictionary + dictionary_idx[idx]; 
      if (*(grid+grid_idx) != '\n'){
        if (contain(grid + grid_idx, word, 1, linewidth - 1)) {
          found = 1;
          print_int(grid_idx/linewidth);
          print_char(',');  
          print_int(grid_idx%linewidth);
          printf(" H ");
          print_word(word);
          print_char('\n');
        }
        if (contain(grid + grid_idx, word, linewidth, size)) {
          found = 1;
          print_int(grid_idx/linewidth);
          print_char(',');  
          print_int(grid_idx%linewidth);
          printf(" V ");
          print_word(word);
          print_char('\n');
        }
        if (contain(grid + grid_idx, word, linewidth + 1, 0)) {
          found = 1;
          print_int(grid_idx/linewidth);
          print_char(',');  
          print_int(grid_idx%linewidth);
          printf(" D ");
          print_word(word);
          print_char('\n');
        }
      }
    }

    grid_idx++;
  }
  if (!found){
    print_string("-1\n");
  }
}

//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{

  int dict_idx = 0;
  int start_idx = 0;
  int width = 0;

  /////////////Reading dictionary and grid files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;


  // open grid file
  FILE *grid_file = fopen(grid_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the grid file failed
  if(grid_file == NULL){
    print_string("Error in opening grid file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }
  // reading the grid file
  do {
    c_input = fgetc(grid_file);
    // indicates the the of file
    if(feof(grid_file)) {
      grid[idx] = '\0';
      break;
    }
    grid[idx] = c_input;
    idx += 1;

  } while (1);

  // closing the grid file
  fclose(grid_file);
  idx = 0;
   
  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);


  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ///////////////You can add your code here!//////////////////////
  idx = 0;
  do {
    c_input = dictionary[idx];
    if(c_input == '\0') {
      break;
    }
    if(c_input == '\n') {
      dictionary_idx[dict_idx ++] = start_idx;
      start_idx = idx + 1;
    }
    idx += 1;
  } while (1);

  dict_num_words = dict_idx;

  
  while (grid[linewidth] != '\n'){
    linewidth += 1;
  }
  linewidth += 1;

  int count = 0;
  while (grid[count] != '\0'){
    if (grid[count] == '\n'){
      rows++;
    }
    count++;
  }

  size = rows * linewidth;

  strfind();

  return 0;
}
