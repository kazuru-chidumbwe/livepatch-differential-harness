#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <linux/kcov.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>

#define COVER_SIZE (256 * 1024)

static void err(const char *tag)
{
	printf("KCOV_ERR=%s errno=%d (%s)\n", tag, errno, strerror(errno));
}

int main(int argc, char **argv)
{
	const char *path = argc > 1 ? argv[1] : "/proc/version";
	int kcov_fd = open("/sys/kernel/debug/kcov", O_RDWR);
	unsigned long *cover;
	unsigned long n;
	int cov_fd;
	char buf[4096];

	if (kcov_fd < 0) {
		err("open_failed");
		return 1;
	}
	if (ioctl(kcov_fd, KCOV_INIT_TRACE, COVER_SIZE)) {
		err("init_failed");
		return 1;
	}
	cover = mmap(NULL, COVER_SIZE * sizeof(unsigned long),
		     PROT_READ | PROT_WRITE, MAP_SHARED, kcov_fd, 0);
	if (cover == MAP_FAILED) {
		err("mmap_failed");
		return 1;
	}
	/* KCOV_TRACE_PC (0) — KCOV_TRACE_CMP is 1 and is not what we want */
	if (ioctl(kcov_fd, KCOV_ENABLE, KCOV_TRACE_PC)) {
		err("enable_failed");
		return 1;
	}

	cov_fd = open(path, O_RDONLY);
	if (cov_fd < 0) {
		err("proc_open_failed");
		return 1;
	}
	while (read(cov_fd, buf, sizeof(buf)) > 0)
		;
	close(cov_fd);

	if (ioctl(kcov_fd, KCOV_DISABLE, 0)) {
		err("disable_failed");
		return 1;
	}

	n = __atomic_load_n(&cover[0], __ATOMIC_RELAXED);
	printf("KCOV_BB_HITS=%lu\n", n);
	printf("KCOV_PATH=%s\n", path);
	return 0;
}
