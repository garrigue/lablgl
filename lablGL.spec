%define	name	 lablgl
%define ver      0.98
%define rel      1
%define prefix   /usr/local/
%define sysconfdir /etc/
%define exec_prefix /usr/local/bin/
%define bindir /usr/local/bin/
%define libdir /usr/lib/ocaml/
%define includedir /usr/local/include/

Summary: LablGL is an OpenGL interface for Objective Caml
Name: %{name}
Version: %{ver}
Release: %{rel}
Copyright: BSD
Group: System Environment/Libraries
Source: http://wwwfun.kurims.kyoto-u.ac.jp/soft/olabl/dist/%{name}-%{ver}.tar.gz
Patch0: lablGL.patch
BuildRoot: %{_tmppath}/%{name}-root
Packager: Ben Martin <monkeyiq@users.sourceforge.net>
URL: http://wwwfun.kurims.kyoto-u.ac.jp/soft/olabl/lablgl.html

%description
LablGL is is an Objective Caml interface to OpenGL. Support is included for use inside LablTk, and LablGTK also includes specific support for LablGL.

It can be used either with proprietary OpenGL implementations (SGI, Digital Unix, Solaris...), with XFree86 GLX extension, or with open-source Mesa.

%prep -q
rm -rf $RPM_BUILD_ROOT;


%setup -q -n  lablGL-%{ver}
%patch0 -p1

%build

cp Makefile.config.ex Makefile.config

if [ "$SMP" != "" ]; then
  (make "MAKE=make -k -j $SMP"; exit 0)
  make 
else
  make 
fi

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{bindir}
make \
	prefix=$RPM_BUILD_ROOT%{prefix} \
	sysconfdir=$RPM_BUILD_ROOT%{sysconfdir} \
	exec_prefix=$RPM_BUILD_ROOT%{exec_prefix} \
	bindir=$RPM_BUILD_ROOT%{bindir} \
	libdir=$RPM_BUILD_ROOT%{libdir} \
	includedir=$RPM_BUILD_ROOT%{includedir} \
	LIBDIR=$RPM_BUILD_ROOT%{libdir} \
	BINDIR=$RPM_BUILD_ROOT%{bindir} \
	install


%clean
rm -rf $RPM_BUILD_ROOT

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-,root,root,0755)
%doc AUTHORS README COPYING ChangeLog INSTALL
%{bindir}/*
%{libdir}/*

%changelog
* Thu Apr 22 2002 Ben Martin
- Created 
