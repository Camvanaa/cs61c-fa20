/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				YOUR NAME HERE
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

//Determines what color the cell at the given row/col should be. This should not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col)
{
	uint32_t cols = image->cols;
	Color **colors = image->image;

	Color *color = colors[cols * row + col];
	Color *new_color = malloc(sizeof(Color));
	if (new_color == NULL) {
		return NULL;
	}

	new_color->R = color->R;
	new_color->G = color->G;
	new_color->B = color->B;

	return new_color;
}

//Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image)
{
	Image *new_image = malloc(sizeof(Image));
	if (new_image == NULL) {
		return NULL;
	}
	new_image->image = (Color**)malloc(image->rows * image->cols * sizeof(Color*));
	if (new_image->image == NULL) {
		free(new_image);
		return NULL;
	}
	new_image->rows = image->rows;
	new_image->cols = image->cols;

	for (int i = 0; i < image->rows; i++) {
		for (int j = 0; j < image->cols; j++) {

			Color *color = evaluateOnePixel(image, i, j);
			if (color == NULL) {
				freeImage(new_image);
				return NULL;
			}
			new_image->image[image->cols * i + j] = color;

			if (color->B & 1) {
				color->R = 255;
				color->G = 255;
				color->B = 255;
			} else {
				color->R = 0;
				color->G = 0;
				color->B = 0;
			}
		}
	}
	return new_image;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with printf) a new image, 
where each pixel is black if the LSB of the B channel is 0, 
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not necessarily with .ppm file extension).
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!
*/
int main(int argc, char **argv)
{
	if (argc != 2) {
		return -1;
	}
	Image *image = readData(argv[1]);
	if (image == NULL) {
		return -1;
	}
	Image *new_image = steganography(image);
	if (new_image == NULL) {
		freeImage(image);
		return -1;
	}

	writeData(new_image);

	freeImage(image);
	freeImage(new_image);

	return 0;
}
