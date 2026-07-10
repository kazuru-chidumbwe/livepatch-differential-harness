// LP-CORPUS-03 — seq_puts + seq_putc (same-signature swap target)
#define pr_fmt(fmt) "lp-corpus-03: " fmt

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>
#include <linux/module.h>
#include <linux/seq_file.h>

static int hb_version_proc_show(struct seq_file *m, void *v)
{
	static const char msg[] = "LP-PILOT-02 patched-by-harness!\n";

	seq_puts(m, msg);
	seq_putc(m, '!');
	return 0;
}

static struct klp_func hb_funcs[] = {
	{
		.old_name = "version_proc_show",
		.new_func = hb_version_proc_show,
	},
	{ }
};

static struct klp_object hb_objs[] = {
	{
		.funcs = hb_funcs,
	},
	{ }
};

static struct klp_patch hb_patch = {
	.mod = THIS_MODULE,
	.objs = hb_objs,
};

static int __init hb_version_init(void)
{
	return klp_enable_patch(&hb_patch);
}

static void __exit hb_version_exit(void)
{
}

module_init(hb_version_init);
module_exit(hb_version_exit);
MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
