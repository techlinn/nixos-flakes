{ ... }:
{
  # Runtime kernel knobs. Grouped: info-leak, filesystem, memory, bpf, misc.
  boot.kernel.sysctl = {
    # Don't leak kernel internals to unprivileged users.
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.perf_event_paranoid" = 3;
    "kernel.yama.ptrace_scope" = 1;
    "kernel.unprivileged_bpf_disabled" = 2;
    "kernel.sysrq" = 0;
    "kernel.kexec_load_disabled" = 1;
    "kernel.randomize_va_space" = 2;

    # Harden BPF JIT; no symbols leaked.
    "net.core.bpf_jit_harden" = 2;
    "net.core.bpf_jit_kallsyms" = 0;

    "dev.tty.ldisc_autoload" = 0;

    # Filesystem: protect regular files, pipes, symlinks, hardlinks.
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.suid_dumpable" = 0;

    # Memory: more ASLR entropy, no low-address mapping, no userfaultfd.
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
    "vm.mmap_min_addr" = 65536;
    "vm.unprivileged_userfaultfd" = 0;
  };
}
