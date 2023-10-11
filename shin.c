#include <stdio.h>
#include <string.h>
#include <unistd.h>

// FUNCTIONS


// MAIN

int main(int argc, char *argv[]) {

	// Allocate 2 more bytes for NULL and newline character
	char game_id[17];
	char game_name[52];

	if (argc > 1) {

		if (strncmp(argv[1], "add", 3) == 0) {

			if (argc < 2 || !(access(argv[2], F_OK) == 0)) {
				printf("No game path argument passed or file does not exist\n");
				return 1;

			}

			printf("Please enter the game ID This will be used to identify your game when using the 'run' operation\n>> ");
			fgets(game_id, 17, stdin);

			printf("Enter the game name\n>> ");
			fgets(game_name, 52, stdin);

		} else if (strncmp(argv[1], "run", 3) == 0) {
			printf("running\n");

		} else {
			printf("help\n");
		}

	} else {
		printf("help\n");

	}

	return 0;
}
