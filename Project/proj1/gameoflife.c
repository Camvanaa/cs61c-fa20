/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

uint8_t getChannel(Color *color, int channel)
{
	if (channel == 0) {
		return color->R;
	} else if (channel == 1) {
		return color->G;
	}
	return color->B;
}

uint8_t scan(Image *image, int row, int col, uint32_t rule, int channel)
{
	uint32_t rows = image->rows;
	uint32_t cols = image->cols;
	Color **colors = image->image;
	uint8_t target_color = getChannel(colors[cols * row + col], channel);
	uint8_t new_single_color = 0;

	for (int i = 0; i < 8; i++) {
		uint8_t self = (target_color >> i) & 1;
		uint8_t alive = 0;
		int up = (row + rows - 1) % rows;
		int down = (row + 1) % rows;
		int left = (col + cols - 1) % cols;
		int right = (col + 1) % cols;

		if ((getChannel(colors[cols * row + right], channel) >> i) & 1) alive++;
		if ((getChannel(colors[cols * row + left], channel) >> i) & 1) alive++;
		if ((getChannel(colors[cols * up + col], channel) >> i) & 1) alive++;
		if ((getChannel(colors[cols * down + col], channel) >> i) & 1) alive++;
		if ((getChannel(colors[cols * up + right], channel) >> i) & 1) alive++;
		if ((getChannel(colors[cols * up + left], channel) >> i) & 1) alive++;
		if ((getChannel(colors[cols * down + right], channel) >> i) & 1) alive++;
		if ((getChannel(colors[cols * down + left], channel) >> i) & 1) alive++;

		int index;
		if (self) {
			index = alive + 9;
		} else {
			index = alive;
		}

		if ((rule >> index) & 1) {
			new_single_color |= (1 << i);
		}
	}

	return new_single_color;
}

//Determines what color the cell at the given row/col should be. This function allocates space for a new Color.
//Note that you will need to read the eight neighbors of the cell in question. The grid "wraps", so we treat the top row as adjacent to the bottom row
//and the left column as adjacent to the right column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule)
{
	Color *new_color = malloc(sizeof(Color));
	if (new_color == NULL) {
		return NULL;
	}

	new_color->R = scan(image, row, col, rule, 0);
	new_color->G = scan(image, row, col, rule, 1);
	new_color->B = scan(image, row, col, rule, 2);

	return new_color;
}

//The main body of Life; given an image and a rule, computes one iteration of the Game of Life.
//You should be able to copy most of this from steganography.c
Image *life(Image *image, uint32_t rule)
{
	Image *new_image = malloc(sizeof(Image));
	if (new_image == NULL) {
		return NULL;
	}

	new_image->rows = image->rows;
	new_image->cols = image->cols;
	new_image->image = malloc(image->rows * image->cols * sizeof(Color *));
	if (new_image->image == NULL) {
		free(new_image);
		return NULL;
	}

	for (uint32_t i = 0; i < image->rows; i++) {
		for (uint32_t j = 0; j < image->cols; j++) {
			new_image->image[image->cols * i + j] = evaluateOneCell(image, i, j, rule);
			if (new_image->image[image->cols * i + j] == NULL) {
				for (uint32_t k = 0; k < image->cols * i + j; k++) {
					free(new_image->image[k]);
				}
				free(new_image->image);
				free(new_image);
				return NULL;
			}
		}
	}

	return new_image;
}

/*
Loads a .ppm from a file, computes the next iteration of the game of life, then prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this will be a string.
You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
int main(int argc, char **argv)
{
	if (argc != 3) {
		printf("usage: ./gameOfLife filename rule\n");
		printf("filename is an ASCII PPM file (type P3) with maximum value 255.\n");
		printf("rule is a hex number beginning with 0x; Life is 0x1808.\n");
		return -1;
	}
	char *endptr;
	uint32_t rule = (uint32_t) strtol(argv[2], &endptr, 16);
	char *filename = argv[1];
	Image *image = readData(filename);
	Image *new_image;

	if (image == NULL || *endptr != '\0') {
		return -1;
	}

	new_image = life(image, rule);
	if (new_image == NULL) {
		freeImage(image);
		return -1;
	}

	writeData(new_image);
	freeImage(image);
	freeImage(new_image);
	return 0;

}
