use anyhow::anyhow;
use lambdaworks_crypto::merkle_tree::traits::IsMerkleTreeBackend;
use serde::{Deserialize, Serialize};
use sha3::{Digest, Keccak256};

#[derive(Debug, Serialize, Deserialize, Default, Clone, PartialEq)]
pub enum ProvingSystemId {
    GnarkPlonkBls12_381,
    GnarkPlonkBn254,
    Groth16Bn254,
    #[default]
    SP1,
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct VerificationData {
    pub proving_system: ProvingSystemId,
    pub proof: Vec<u8>,
    pub public_input: Option<Vec<u8>>,
    pub verification_key: Option<Vec<u8>>,
    pub vm_program_code: Option<Vec<u8>>,
}

#[derive(Debug, Default, Serialize, Deserialize)]
pub struct VerificationBatch(Vec<VerificationData>);

impl IsMerkleTreeBackend for VerificationBatch {
    type Node = [u8; 32];
    type Data = VerificationData;

    fn hash_data(leaf: &Self::Data) -> Self::Node {
        let leaf_bytes = bincode::serialize(leaf).expect("Failed to serialize leaf");
        let mut hasher = Keccak256::new();
        hasher.update(&leaf_bytes);
        hasher.finalize().into()
    }

    fn hash_new_parent(child_1: &Self::Node, child_2: &Self::Node) -> Self::Node {
        let mut hasher = Keccak256::new();
        hasher.update(child_1);
        hasher.update(child_2);
        hasher.finalize().into()
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn hash_new_parent_is_correct() {
        let mut hasher1 = Keccak256::new();
        hasher1.update(vec![1u8]);
        let child_1 = hasher1.finalize().into();

        let mut hasher2 = Keccak256::new();
        hasher2.update(vec![2u8]);
        let child_2 = hasher2.finalize().into();

        let parent = VerificationBatch::hash_new_parent(&child_1, &child_2);

        // This value is built using Openzeppelin's module for Merkle Trees, in particular using
        // the SimpleMerkleTree. For more details see the openzeppelin_merkle_tree/merkle_tree.js script.
        let expected_parent = "71d8979cbfae9b197a4fbcc7d387b1fae9560e2f284d30b4e90c80f6bc074f57";

        assert_eq!(hex::encode(parent), expected_parent)
    }
}

pub fn get_proving_system_from_str(proving_system: &str) -> anyhow::Result<ProvingSystemId> {
    match proving_system {
        "GnarkPlonkBls12_381" => Ok(ProvingSystemId::GnarkPlonkBls12_381),
        "GnarkPlonkBn254" => Ok(ProvingSystemId::GnarkPlonkBn254),
        "Groth16Bn254" => Ok(ProvingSystemId::Groth16Bn254),
        "SP1" => Ok(ProvingSystemId::SP1),
        _ => Err(anyhow!("Invalid proving system: {}, Available proving systems are: [GnarkPlonkBls12_381, GnarkPlonkBn254, Groth16Bn254, SP1]", proving_system))
    }
}
