.PHONY: smoke gate0 gate1 reproduce test verify-manifest

smoke:
	bash scripts/quick_test.sh

gate0:
	bash scripts/run_gate0.sh

gate1:
	bash scripts/run_gate1.sh

reproduce:
	bash scripts/reproduce.sh

test:
	python3 -m pytest classifier/tests -q 2>/dev/null || python3 classifier/matrix.py --self-test

verify-manifest:
	@test -n "$(RESULTS_DIR)" || (echo "usage: make verify-manifest RESULTS_DIR=results/<run-id>" && exit 1)
	python3 classifier/verify_manifest.py "$(RESULTS_DIR)"
