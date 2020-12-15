BASEDIR  = $(shell pwd)
REBAR = ./rebar3

CT_OPTS_DIST = -erl_args

DEPS_PATH = $(shell rebar3 as test path)

RELPATH = _build/default/rel/flow
DEV1RELPATH = _build/dev1/rel/flow
DEV2RELPATH = _build/dev2/rel/flow
DEV3RELPATH = _build/dev3/rel/flow
APPNAME = flow


ifdef SUITE
CT_OPTS_SUITE = --suite test/${SUITE}
else
CT_OPTS_SUITE =
endif


all: compile

compile:
	$(REBAR) compile

format:
	$(REBAR) format

clean:
	rm -rf ebin/* test/*.beam logs log
	$(REBAR) clean

dialyzer:
	$(REBAR) dialyzer

compile_tests:
	$(REBAR) as test compile

unit: compile_tests
	$(REBAR) eunit

test: compile_tests
	$(REBAR) ct --sname ct --readable true $(CT_OPTS_SUITE)


rel:
	$(REBAR) release


console:
	cd $(RELPATH) && ./bin/flow console


devrel: dev1rel dev2rel dev3rel


dev1rel:
	$(REBAR) as dev1 release
dev2rel:
	$(REBAR) as dev2 release
dev3rel:
	$(REBAR) as dev3 release

dev1-console:
	$(BASEDIR)/_build/dev1/rel/flow/bin/flow console
dev2-console:
	$(BASEDIR)/_build/dev2/rel/flow/bin/flow console
dev3-console:
	$(BASEDIR)/_build/dev3/rel/flow/bin/flow console

