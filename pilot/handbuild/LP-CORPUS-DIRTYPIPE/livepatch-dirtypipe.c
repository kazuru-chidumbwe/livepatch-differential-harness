/*
 * Hand-built livepatch skeleton for Dirty Pipe fix (CVE-2022-0847).
 * Pin: vulnerable tree v5.16.10 — NOT the package v6.6.47 case-study pin.
 *
 * Replace symbols / body with the upstream fix from v5.16.11 once the
 * Option A tree is configured and the changed functions are identified
 * (typically pipe buffer flag initialization paths under fs/pipe.c).
 *
 * Until then this file documents the package-honest stance: capstone is a
 * separate pin, not claimed on v6.6.47.
 */
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>

MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
MODULE_AUTHOR("Seke Kazuru");
MODULE_DESCRIPTION("LP-CORPUS-DIRTYPIPE skeleton — fill after Option A pin boots");

/* Placeholder — real replacement functions go here after pin analysis. */
static struct klp_func funcs[] = {
	{ }
};

static struct klp_object objs[] = {
	{
		.name = NULL, /* vmlinux */
		.funcs = funcs,
	},
	{ }
};

static struct klp_patch patch = {
	.mod = THIS_MODULE,
	.objs = objs,
};

static int livepatch_init(void)
{
	return klp_enable_patch(&patch);
}

static void livepatch_exit(void)
{
}

module_init(livepatch_init);
module_exit(livepatch_exit);
