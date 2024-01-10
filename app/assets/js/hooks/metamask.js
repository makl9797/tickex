import { ethers } from "ethers"

const web3Provider = new ethers.providers.Web3Provider(window.ethereum)

export const Metamask = {
    mounted() {
        let signer = web3Provider.getSigner()

        web3Provider.listAccounts().then((accounts) => {
            if (accounts.length < 1) {
                this.pushEvent("metamask-disconnected", {})
            }

        })

        this.handleEvent("verify-wallet", data => {
            signer.getAddress().then((address) => {
                const message = `You are signing this message to sign in with Tickex. Nonce: ${data.nonce}`;

                signer.signMessage(message).then((signature) => {
                    this.pushEvent("verify-signature", { public_address: address, signature: signature });
                }).catch((error) => {
                    this.pushEvent("signature-failed", {});
                });
            });
        })

        this.handleEvent("connect-metamask", data => {
            web3Provider.provider.request({ method: 'eth_requestAccounts' }).then((accounts) => {
                if (accounts.length > 0) {
                    signer.getAddress().then((address) => {
                        this.pushEvent("metamask-connected", { public_address: address })
                    });
                }
            }, (error) => console.log(error))
        })
    },
}
