#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/livepatch.h>
#include <linux/seq_file.h>
#include <linux/gfp.h>
/* Undef ref keeps klp_shadow_alloc visible to PRE(A) nm -u. */
extern void *klp_shadow_alloc(void *obj, unsigned long id, size_t size, gfp_t gfp,
			     void (*ctor)(void *, void *), void *ctor_data);
MODULE_LICENSE("GPL");
MODULE_INFO(livepatch, "Y");
static void *volatile keep_shadow;
static int show(struct seq_file *m, void *v) { seq_puts(m, "SHADOW-STUB\n"); return 0; }
static struct klp_func funcs[] = { { .old_name = "version_proc_show", .new_func = show }, { } };
static struct klp_object objs[] = { { .name = NULL, .funcs = funcs }, { } };
static struct klp_patch patch = { .mod = THIS_MODULE, .objs = objs };
static int __init init(void) {
	keep_shadow = (void *)klp_shadow_alloc;
	return klp_enable_patch(&patch);
}
static void __exit exitfn(void) {}
module_init(init); module_exit(exitfn);
