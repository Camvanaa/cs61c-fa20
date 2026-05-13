/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include "imageloader.h"

//Opens a .ppm P3 image file, and constructs an Image object. 
//You may find the function fscanf useful.
//Make sure that you close the file with fclose before returning.
Image *readData(char *filename) 
{
	FILE *fp = fopen(filename, "r");
	char format[3];
	int width, height, scale;
	fscanf(fp, "%s %d %d %d", format, &width, &height, &scale);

	Image *image = malloc(sizeof(Image));
	image->cols = (uint32_t)width;
	image->rows = (uint32_t)height;
	image->image = (Color**)malloc(width * height * sizeof(Color*));
	for(int i=0; i<width*height; i++) {
		int R, G, B;
		fscanf(fp, "%d %d %d", &R, &G, &B);
		Color *color = malloc(sizeof(Color));
		color->R = (uint8_t)R;
		color->G = (uint8_t)G;
		color->B = (uint8_t)B;
		image->image[i] = color;
	}
	fclose(fp);
	return image;
}

//Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the image's data.
void writeData(Image *image)
{
	printf("P3\n");
	printf("%d %d\n", image->cols, image->rows);
	printf("255\n");
	for (int i=0; i<image->rows; i++) {
		for (int j=0; j<image->cols; j++) {
			uint8_t R, G, B;
			R = image->image[i*image->cols + j]->R;
			G = image->image[i*image->cols + j]->G;
			B = image->image[i*image->cols + j]->B;
			printf("%3d %3d %3d", R, G, B);
			if (j != image->cols - 1) {
				printf("   ");
			}
		}
		printf("\n");
	}
}

//Frees an image
void freeImage(Image *image)
{
	uint32_t cols = image->cols;
	uint32_t rows = image->rows;
	for (int i = 0; i < rows * cols; i++) {
		free(image->image[i]);
	}
	free(image->image);
	free(image);
}