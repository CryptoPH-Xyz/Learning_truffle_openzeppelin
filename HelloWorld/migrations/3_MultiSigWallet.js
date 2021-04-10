const MultiSigWallet = artifacts.require("MultiSigWallet");

module.exports = function (deployer, network, accounts) {
    var sigRequired = 2;
    deployer.deploy(MultiSigWallet, ['0x6EF694F14D5633eFfE6190eF56BBCDBb6BC7560C',
    '0x2C202FFc76A4E0440a10735d706747a768f7F17d','0xFaA0734ab190D1B5C3eF428f7aedE11Be2b8AE46',
    '0xC4c838CBE714dEAae536DBE11886eBECe53864B7'], sigRequired);
};
