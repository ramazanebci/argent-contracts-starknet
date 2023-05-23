use array::ArrayTrait;
use traits::Into;

use multisig::ArgentMultisigAccount;

const message_hash: felt252 = 424242;

const signer_pubkey_1: felt252 = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
const signer_1_signature_r: felt252 =
    780418022109335103732757207432889561210689172704851180349474175235986529895;
const signer_1_signature_s: felt252 =
    117732574052293722698213953663617651411051623743664517986289794046851647347;

const signer_pubkey_2: felt252 = 0x759CA09377679ECD535A81E83039658BF40959283187C654C5416F439403CF5;
const signer_2_signature_r: felt252 =
    2543572729543774155040746789716602521360190010191061121815852574984983703153;
const signer_2_signature_s: felt252 =
    3047778680024311010844701802416003052323696285920266547201663937333620527443;

use lib::{ERC1271_VALIDATED};

#[test]
#[available_gas(20000000)]
fn test_signature() {
    let threshold = 1;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    ArgentMultisigAccount::constructor(threshold, signers_array);

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    let valid_signature = ArgentMultisigAccount::is_valid_signature(message_hash, signature);
    assert(valid_signature == ERC1271_VALIDATED, 'bad signature');
}

#[test]
#[available_gas(20000000)]
fn test_double_signature() {
    // init
    let threshold = 2;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    signers_array.append(signer_pubkey_2);
    ArgentMultisigAccount::constructor(threshold, signers_array);

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    signature.append(signer_pubkey_2);
    signature.append(signer_2_signature_r);
    signature.append(signer_2_signature_s);
    let valid_signature = ArgentMultisigAccount::is_valid_signature(message_hash, signature);
    assert(valid_signature == ERC1271_VALIDATED, 'bad signature');
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/signatures-not-sorted', ))]
fn test_double_signature_order() {
    let threshold = 2;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    signers_array.append(signer_pubkey_2);
    ArgentMultisigAccount::constructor(threshold, signers_array);

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_2);
    signature.append(signer_2_signature_r);
    signature.append(signer_2_signature_s);
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    ArgentMultisigAccount::is_valid_signature(message_hash, signature);
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/signatures-not-sorted', ))]
fn test_same_owner_twice() {
    let threshold = 2;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    signers_array.append(signer_pubkey_2);
    ArgentMultisigAccount::constructor(threshold, signers_array);

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    ArgentMultisigAccount::is_valid_signature(message_hash, signature);
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/invalid-signature-length', ))]
fn test_missing_owner_signature() {
    let threshold = 2;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    signers_array.append(signer_pubkey_2);
    ArgentMultisigAccount::constructor(threshold, signers_array);

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    ArgentMultisigAccount::is_valid_signature(message_hash, signature);
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/invalid-signature-length', ))]
fn test_short_signature() {
    let threshold = 1;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    ArgentMultisigAccount::constructor(threshold, signers_array);

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    signature.append(signer_pubkey_1);
    signature.append(signer_1_signature_r);
    signature.append(signer_1_signature_s);
    ArgentMultisigAccount::is_valid_signature(message_hash, signature);
}

#[test]
#[available_gas(20000000)]
#[should_panic(expected: ('argent/invalid-signature-length', ))]
fn test_long_signature() {
    let threshold = 1;
    let mut signers_array = ArrayTrait::new();
    signers_array.append(signer_pubkey_1);
    ArgentMultisigAccount::constructor(threshold, signers_array);

    let mut signature = ArrayTrait::<felt252>::new();
    signature.append(42);
    ArgentMultisigAccount::is_valid_signature(message_hash, signature);
}
