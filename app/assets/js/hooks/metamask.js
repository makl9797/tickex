import { ethers } from "ethers"

const web3Provider = new ethers.providers.Web3Provider(window.ethereum)

export const Metamask = {
    mounted() {
        let signer = web3Provider.getSigner()

        window.addEventListener('load', async () => {
            web3Provider.listAccounts().then((accounts) => {
                if (accounts.length < 1) {
                    this.pushEvent("metamask-disconnected", {})
                }
            })
        })

        window.addEventListener(`phx:verify-wallet`, (e) => {
            signer.getAddress().then((address) => {
                const message = `You are signing this message to sign in with Tickex. Nonce: ${e.detail.nonce}`

                signer.signMessage(message).then((signature) => {
                    this.pushEvent("verify-signature", { public_address: address, signature: signature })

                    return;
                })
            })
        })

        window.addEventListener(`phx:connect-metamask`, (e) => {
            web3Provider.provider.request({ method: 'eth_requestAccounts' }).then((accounts) => {
                if (accounts.length > 0) {
                    signer.getAddress().then((address) => {
                        this.pushEvent("metamask-connected", { public_address: address, connected: true})
                    });
                }
            }, (error) => console.log(error))
        })
    },
}
