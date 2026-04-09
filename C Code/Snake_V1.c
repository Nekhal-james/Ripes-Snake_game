typedef unsigned int uint32_t;

// --- Peripheral Memory Mapping ---
#define D_PAD_UP      ((volatile uint32_t*)0xf0000000)
#define D_PAD_DOWN    ((volatile uint32_t*)0xf0000004)
#define D_PAD_LEFT    ((volatile uint32_t*)0xf0000008)
#define D_PAD_RIGHT   ((volatile uint32_t*)0xf000000c)
#define LED_MATRIX    ((volatile uint32_t*)0xf0000010)

#define WIDTH  20
#define HEIGHT 20
#define MAX_LENGTH 100

#define COLOR_SNAKE 0xFF00FF00
#define COLOR_FOOD  0xFFFF0000
#define COLOR_BG    0xFF000000
#define COLOR_SCORE 0xFFFFFF00 

typedef enum { UP, DOWN, LEFT, RIGHT } Direction;

struct { int x, y; } snake[MAX_LENGTH];
int length = 5;
int food_x = 10, food_y = 10;
Direction current_dir = RIGHT;

void handle_input() {
    // Polling with 'else if' to ensure only one direction is registered
    if (*D_PAD_UP    && current_dir != DOWN)  current_dir = UP;
    else if (*D_PAD_DOWN  && current_dir != UP)    current_dir = DOWN;
    else if (*D_PAD_LEFT  && current_dir != RIGHT) current_dir = LEFT;
    else if (*D_PAD_RIGHT && current_dir != LEFT)  current_dir = RIGHT;
}

void draw_pixel(int x, int y, uint32_t color) {
    if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT) {
        LED_MATRIX[y * WIDTH + x] = color;
    }
}

void reset_game() {
    length = 5;
    current_dir = RIGHT;
    for(int i = 0; i < length; i++) {
        snake[i].x = 5 - i;
        snake[i].y = 10;
    }
}

void update_physics() {
    for (int i = length - 1; i > 0; i--) {
        snake[i].x = snake[i - 1].x;
        snake[i].y = snake[i - 1].y;
    }

    if (current_dir == UP)    snake[0].y--;
    else if (current_dir == DOWN)  snake[0].y++;
    else if (current_dir == LEFT)  snake[0].x--;
    else if (current_dir == RIGHT) snake[0].x++;

    // Boundaries
    if (snake[0].x < 0) snake[0].x = WIDTH - 1;
    if (snake[0].x >= WIDTH) snake[0].x = 0;
    if (snake[0].y < 1) snake[0].y = HEIGHT - 1; 
    if (snake[0].y >= HEIGHT) snake[0].y = 1;

    // Self-Collision
    for (int i = 1; i < length; i++) {
        if (snake[0].x == snake[i].x && snake[0].y == snake[i].y) {
            reset_game();
            return;
        }
    }

    // Food
    if (snake[0].x == food_x && snake[0].y == food_y) {
        if (length < MAX_LENGTH) length++;
        food_x = (food_x + 7) % WIDTH;
        food_y = 1 + ((food_y + 3) % (HEIGHT - 1));
    }
}

int main() {
    reset_game();
    while (1) {
        update_physics();

        // 1. FULL CLEAR every frame (Fixes the green dots trail)
        for (int i = 0; i < WIDTH * HEIGHT; i++) LED_MATRIX[i] = COLOR_BG;

        // 2. Draw Score
        for (int i = 0; i < (length - 5); i++) draw_pixel(i, 0, COLOR_SCORE);

        // 3. Draw Food
        draw_pixel(food_x, food_y, COLOR_FOOD);

        // 4. Draw Snake
        for (int i = 0; i < length; i++) {
            draw_pixel(snake[i].x, snake[i].y, COLOR_SNAKE);
        }

        // 5. RESPONSIVE DELAY (Crucial for WASD)
        // We poll input 10,000 times during the wait.
        // If the game is too slow, decrease 10000. If too fast, increase it.
        for (volatile int i = 0; i < 500; i++) {
            handle_input();
        }
    }
}