// Copyright (c) RoochNetwork
// SPDX-License-Identifier: Apache-2.0

import React, { ReactNode, useState } from 'react'
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogContentText,
  DialogTitle,
  TextField,
} from '@mui/material'

// ** Hooks Import
import { useCurrentSession, useCreateSessionKey } from '@roochnetwork/rooch-sdk-kit'

interface Props {
  open: boolean
  onReqAuthorize: (scope: Array<string>, maxInactiveInterval: number) => void
  onLogout?: () => void
}

const defaultScope = [
  '0x1::*::*',
  '0x3::*::*',
  '0x49ee3cf17a017b331ab2b8a4d40ecc9706f328562f9db63cba625a9c106cdf35::*::*',
]

const AuthDialog: React.FC<Props> = ({ open, onReqAuthorize, onLogout }) => {
  const [scope, setScope] = useState<Array<string>>(defaultScope)
  const [maxInactiveInterval, setMaxInactiveInterval] = useState<number>(1200)

  const handleAuth = () => {
    onReqAuthorize && onReqAuthorize(scope, maxInactiveInterval)
  }

  return (
    <Dialog open={open} onClose={onLogout}>
      <DialogTitle>Session Authorize</DialogTitle>
      <DialogContent>
        <DialogContentText>
          The current session does not exist or has expired. Please authorize the creation of a new
          session.
        </DialogContentText>
        <TextField
          autoFocus
          margin="dense"
          id="scope"
          label="Scope"
          type="text"
          multiline
          fullWidth
          disabled
          variant="standard"
          value={scope.join('\n')}
          onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
            setScope(event.target.value.split('\n'))
          }}
        />
        <TextField
          autoFocus
          margin="dense"
          id="max_inactive_interval"
          label="Max Inactive Interval"
          type="text"
          multiline
          fullWidth
          disabled
          variant="standard"
          value={maxInactiveInterval}
          onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
            setMaxInactiveInterval(parseInt(event.target.value))
          }}
        />
      </DialogContent>
      <DialogActions>
        {onLogout ? <Button onClick={onLogout}>Logout</Button> : null}
        <Button onClick={handleAuth}>Authorize</Button>
      </DialogActions>
    </Dialog>
  )
}

interface SessionGuardProps {
  children: ReactNode
}

const SessionGuard = (props: SessionGuardProps) => {
  const { children } = props

  const sessionAccount = useCurrentSession()
  const { mutate: createSessionKey } = useCreateSessionKey()

  const handleAuth = (scope: Array<string>, maxInactiveInterval: number) => {
    // requestAuthorize && requestAuthorize(scope, maxInactiveInterval)
    createSessionKey({
      appName: 'rooch-dashboard',
      appUrl: 'https://dashboard.rooch.network/scan/state/get/',
      scopes: scope,
      maxInactiveInterval: maxInactiveInterval,
    })
  }

  // const isSessionInvalid = () => {
  //   return !initialization && (account === undefined || account === null)
  // }

  return (
    <>
      <AuthDialog open={sessionAccount === null} onReqAuthorize={handleAuth} onLogout={close} />
      {children}
    </>
  )
}

export default SessionGuard
