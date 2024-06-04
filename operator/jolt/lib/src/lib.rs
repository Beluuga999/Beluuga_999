use lazy_static::lazy_static;
pub const MAX_PROOF_SIZE: usize = 2 * 1024 * 1024;
pub const MAX_INFO_BUFFER_SIZE: usize = 1024 * 1024;

#[no_mangle]
pub extern "C" fn verify_jolt_proof_ffi(
    proof_bytes: &[u8; MAX_PROOF_SIZE],
    proof_len: u32,
    info_bytes: &[u8; MAX_INFO_BUFFER_SIZE],
    info_len: u32,
) -> bool {
    let real_info = &elf_bytes[0..elf_len as usize];

    if let Ok(proof) = bincode::deserialize(&proof_bytes[..proof_len as usize]) {
        return true
    }

    false
}

#[cfg(test)]
mod tests {
    use super::*;

    const PROOF: &[u8] =
        include_bytes!("../../../../task_sender/test_examples/sp1/sp1_fibonacci.proof");
    const ELF: &[u8] =
        include_bytes!("../../../../task_sender/test_examples/sp1/elf/riscv32im-succinct-zkvm-elf");

    #[test]
    fn verify_jolt_proof_with_elf_works() {
        let mut proof_buffer = [0u8; MAX_PROOF_SIZE];
        let proof_size = PROOF.len();
        proof_buffer[..proof_size].clone_from_slice(PROOF);

        let mut elf_buffer = [0u8; MAX_ELF_BUFFER_SIZE];
        let elf_size = ELF.len();
        elf_buffer[..elf_size].clone_from_slice(ELF);

        let result = verify_jolt_proof_ffi(&proof_buffer, proof_size, &elf_buffer, elf_size);
        assert!(result)
    }

    #[test]
    fn verify_jolt_aborts_with_bad_proof() {
        let mut proof_buffer = [42u8; super::MAX_PROOF_SIZE];
        let proof_size = PROOF.len();
        proof_buffer[..proof_size].clone_from_slice(PROOF);

        let mut elf_buffer = [0u8; MAX_ELF_BUFFER_SIZE];
        let elf_size = ELF.len();
        elf_buffer[..elf_size].clone_from_slice(ELF);

        let result = verify_jolt_proof_ffi(&proof_buffer, proof_size - 1, &elf_buffer, elf_size);
        assert!(!result)
    }
}
