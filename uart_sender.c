#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <errno.h>
#include <time.h>

int configure_serial(int fd) {
    struct termios options;

    if (tcgetattr(fd, &options) != 0) {
        perror("tcgetattr");
        return -1;
    }

    cfsetispeed(&options, B115200);
    cfsetospeed(&options, B115200);

    options.c_cflag &= ~PARENB;             // No parity
    options.c_cflag &= ~CSTOPB;             // 1 stop bit
    options.c_cflag &= ~CSIZE;
    options.c_cflag |= CS8;                 // 8 data bits
    options.c_cflag |= CLOCAL | CREAD;      // Enable receiver, ignore modem control lines

    options.c_iflag &= ~(IXON | IXOFF | IXANY); // No software flow control
    options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG); // Raw input
    options.c_oflag &= ~OPOST;              // Raw output

    tcflush(fd, TCIOFLUSH); // Clear input/output buffers
    if (tcsetattr(fd, TCSANOW, &options) != 0) {
        perror("tcsetattr");
        return -1;
    }

    return 0;
}

int main() {
    const char *device = "/dev/ttyUSB2";      // Adjust this to your CH341 device
    const char *log_file_path = "uart_log.txt";

    // Open log file
    FILE *log_file = fopen(log_file_path, "w");
    if (!log_file) {
        perror("Unable to open log file");
        return 1;
    }

    // Open serial port
    int fd = open(device, O_RDWR | O_NOCTTY | O_SYNC);
    if (fd == -1) {
        perror("Unable to open UART device");
        fclose(log_file);
        return 1;
    }

    // Configure serial
    if (configure_serial(fd) != 0) {
        close(fd);
        fclose(log_file);
        return 1;
    }

    // Transmit characters 0–9
    for (char c = '0'; c <= '9'; c++) {
        ssize_t bytes_written = write(fd, &c, 1);
        if (bytes_written != 1) {
            perror("write");
            break;
        }

        // Ensure byte is transmitted
        tcdrain(fd);

        // Timestamp log entry
        time_t now = time(NULL);
        char *timestamp = ctime(&now);
        timestamp[strcspn(timestamp, "\n")] = 0;  // Remove newline

        fprintf(log_file, "[%s] Sent: %c\n", timestamp, c);
        fflush(log_file);

        printf("Sent: %c\n", c);
        usleep(3000000); // 3 seconds
    }

    close(fd);
    fclose(log_file);

    return 0;
}
