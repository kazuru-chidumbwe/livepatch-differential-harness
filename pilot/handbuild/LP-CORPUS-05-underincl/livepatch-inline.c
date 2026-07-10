// LP-CORPUS-05 — intentional under-inclusion: patch hot path only (version_proc_show).
// Cold path (version_aux_proc_show) retains inlined INLINE-ORIG at its call site.
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>
#include <linux/module.h>
#include <linux/seq_file.h>

static int hb_version_proc_show(struct seq_file *m, void *v)
{
	seq_puts(m, "INLINE-PATCHED");
	seq_putc(m, '\n');
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
	{ .funcs = hb_funcs },
	{ }
};

static struct klp_patch hb_patch = {
	.mod = THIS_MODULE,
	.objs = hb_objs,
};

static int __init hb_init(void)
{
	return klp_enable_patch(&hb_patch);
}

static void __exit hb_exit(void) { }

module_init(hb_init);
module_exit(hb_exit);
MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
