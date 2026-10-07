Name:           ooyq
Version:        0.1.0
Release:        1%{?dist}
Summary:        Lightweight zero-dependency YAML and JSON cross-transpiler and jq filter engine.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/ooyq
Source0:        ooyq-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
ooyq is a sovereign, capability-bounded YAML PROCESSOR written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/ooyq
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/ooyq-uninstall

%files
/usr/bin/ooyq
/usr/bin/ooyq-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
