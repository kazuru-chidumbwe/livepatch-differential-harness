#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>
#include <linux/seq_file.h>

MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
MODULE_AUTHOR("Seke Kazuru");
MODULE_DESCRIPTION("LP-CORPUS-DIRTYPIPE SoftX pin smoke on v5.16.10");

static int hb_version_proc_show(struct seq_file *m, void *v)
{
	seq_printf(m, "DIRTYPIPE-HARNESS-MARK\n");
	return 0;
}

static struct klp_func funcs[] = {
	{
		.old_name = "version_proc_show",
		.new_func = hb_version_proc_show,
	},
	{ }
};

static struct klp_object objs[] = {
	{
		.name = NULL,
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
