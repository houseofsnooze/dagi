import { useEffect, useState, useRef } from 'react'
import { Payments } from '@nevermined-io/payments'

export default function Nevermined({
    onCheckDone
}: {
    onCheckDone: (hasBalance: boolean) => void
}) {
  const [isUserLoggedIn, setIsUserLoggedIn] = useState<boolean>(false)
  const [creatingSubscription, setCreatingSubscription] = useState<boolean>(false)
  const [did, setDid] = useState<string>("6a3f752509473a4c33abb853e7930b4b577ebae7bfb954f6da2f92279fa6f75f");

  const payments = useRef(
    new Payments({
      returnUrl:
        'https://localhost:3000',
      environment: 'appTesting',
      appId: 'app-docs',
      version: 'v0.1.4',
    }),
  )

  const onLogin = () => {
    payments.current.connect()
  }

  const onLogout = () => {
    payments.current.logout()
    setIsUserLoggedIn(payments.current.isLoggedIn)
  }

  useEffect(() => {
    payments.current.init()
  }, [])

  useEffect(() => {
    if (payments.current.isLoggedIn) {
      setIsUserLoggedIn(true)
    }
  }, [payments.current.isLoggedIn])

  async function check() {
    if (payments.current.isLoggedIn) {
      setCreatingSubscription(true)
      const account = payments.current.accountAddress;
        const out = await payments.current.getSubscriptionBalance(did, account)
        const balance = out.balance;
        if (balance > 0) {
          console.log("You have a balance of", balance)
      setCreatingSubscription(false)
        } else {
          console.log("You don't have a balance")
        }
        onCheckDone(balance > 0);
    }
  }

  return (
    <main>
      <div>
        {!isUserLoggedIn && <button onClick={onLogin}>{'Log in'}</button>}
        {isUserLoggedIn && <button onClick={onLogout}>{'Log out'}</button>}

        <button onClick={check}>Get access</button>
        <p>
          {creatingSubscription && did === '' ? (
            'Creating Subscription, please wait a few seconds...'
          ) : (
            <a href={`https://testing.nevermined.app/subscription/${did}`}>{did}</a>
          )}
        </p>
      </div>
    </main>
  )
}
