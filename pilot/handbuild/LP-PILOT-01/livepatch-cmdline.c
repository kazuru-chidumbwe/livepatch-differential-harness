// LP-PILOT-01 hand-built klp_patch — cmdline_proc_show
// Manually constructed against v6.6.47 livepatch API (see relocation-table.md).
#define pr_fmt(fmt) "lp-pilot-cmdline: " fmt

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>
#include <linux/module.h>
#include <linux/seq_file.h>

static int hb_cmdline_proc_show(struct seq_file *m, void *v)
{
	seq_printf(m, "%s\n", "this has been live patched");
	return 0;
}

static struct klp_func hb_funcs[] = {
	{
		.old_name = "cmdline_proc_show",
		.new_func = hb_cmdline_proc_show,
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

static int __init hb_cmdline_init(void)
{
	return klp_enable_patch(&hb_patch);
}

static void __exit hb_cmdline_exit(void)
{
}

module_init(hb_cmdline_init);
module_exit(hb_cmdline_exit);
MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
