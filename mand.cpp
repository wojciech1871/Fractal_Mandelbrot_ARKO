#include <iostream>
#include <stdlib.h>
#include <SDL2/SDL.h>
#include "generateMand.h"

using namespace std;

int main(int argc, char ** argv)
{
    int N;
    double x_S = 0;
    double y_S = 0;
    double zoom = 1;
    double scale;
    bool leftMouseButtonDown = false;
    bool rightMouseButtonDown = false;
    bool quit = false;
    SDL_Event event;

    cout <<"Submit N -> resolution of Mandelbrot set: ";
    cin >> N;
    cout <<"Submit scale of zooming: ";
    cin >> scale;
    SDL_Init(SDL_INIT_VIDEO);

    SDL_Window *window = SDL_CreateWindow("Mandelbrot Set",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, N, N, 0);

    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, 0);
    SDL_Texture *texture = SDL_CreateTexture(renderer,
        SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STATIC, N, N);
    int* pixels = new int[N * N];

    generateMand(pixels, N, N/2, N/2, &x_S, &y_S, zoom);
    while (!quit)
    {
        SDL_UpdateTexture(texture, NULL, pixels, N * sizeof(Uint32));
        SDL_WaitEvent(&event);

        switch (event.type)
        {
        case SDL_MOUSEBUTTONUP:
          {
            if (event.button.button == SDL_BUTTON_LEFT)
                leftMouseButtonDown = false;
            if (event.button.button == SDL_BUTTON_RIGHT)
                rightMouseButtonDown = false;
            break;
          }
        case SDL_MOUSEBUTTONDOWN:
          {
            if (event.button.button == SDL_BUTTON_LEFT)
                leftMouseButtonDown = true;
            if (event.button.button == SDL_BUTTON_RIGHT)
                rightMouseButtonDown = true;
          }
        case SDL_MOUSEMOTION:
          {
            int mouseX = event.motion.x;
            int mouseY = event.motion.y;
            if (leftMouseButtonDown)
            {
                generateMand(pixels, N, mouseX, mouseY, &x_S, &y_S, zoom);
                zoom *= scale;
            }
            if (rightMouseButtonDown)
            {
                zoom = 1;
                x_S = y_S = 0;
                generateMand(pixels, N, N/2, N/2, &x_S, &y_S, zoom);
            }
            break;
          }
        case SDL_QUIT:
            quit = true;
            break;
        }

        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);
    }

    delete[] pixels;
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
