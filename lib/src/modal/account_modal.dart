import 'package:flutter/material.dart';
import 'package:web3mq/src/api/responses.dart';
import 'package:web3mq/src/client/client.dart';
import 'package:web3mq/src/models/accounts.dart';
import 'package:web3mq/src/ws/models/ws_models.dart';

/// An account modal, for user register, login, password reset.
class AccountModal extends StatefulWidget {
  ///
  AccountModal(
      {super.key,
      this.onRegisterSuccess,
      this.onGenerateCredentialSuccess,
      this.onResetPasswordSuccess,
      required this.client});

  final Web3MQClient client;

  ///
  final void Function(RegisterResult)? onRegisterSuccess;

  final void Function(User)? onGenerateCredentialSuccess;

  final void Function(RegisterResult)? onResetPasswordSuccess;

  @override
  State<AccountModal> createState() => _AccountModalState();
}

///
class _AccountModalState extends State<AccountModal> {
  UserInfo? _userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Account Modal'),
        ),
        body: _userInfo == null
            ? Center(
                child: ElevatedButton(
                  onPressed: _connectWallet,
                  child: const Text('Connect Wallet'),
                ),
              )
            : Column(
                children: [
                  Text('Address: ${_userInfo!.walletAddress}'),
                  Text('UserId: ${_userInfo!.userId}'),
                  TabBar(
                    tabs: [
                      Tab(text: 'Register'),
                      Tab(text: 'Generate Credential'),
                      Tab(text: 'Reset Password'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        RegisterTab(onPressed: _onRegisterPressed),
                        GenerateCredentialTab(
                            onPressed: _onGenerateCredentialPressed),
                        ResetPasswordTab(onPressed: _onResetPasswordPressed),
                      ],
                    ),
                  ),
                ],
              ));
  }

  Future<void> _connectWallet() async {
    try {
      final wallet = await widget.client.walletConnector?.connectWallet();
      if (null == wallet || wallet.accounts.isEmpty) {
        throw Exception('Failed to connect an account');
      }
      final account = Account.from(wallet.accounts.first);
      final userInfo = await widget.client
          .userInfo(CAIP10Helper.walletType(account), account.address);
      setState(() {
        _userInfo = userInfo;
      });
    } catch (e) {
      print('Failed to connect wallet: $e');
    }
  }

  void _onRegisterPressed(String password) {
    final did = DID(_userInfo!.didType, _userInfo!.didValue);
    widget.client.register(did, password).then((value) {
      _handleRegisterSuccess(value);
    });
  }

  void _onGenerateCredentialPressed(String password, Duration duration) {
    final did = DID(_userInfo!.didType, _userInfo!.didValue);
    widget.client
        .userWithDIDAndPassword(did, password, duration)
        .then((value) => _handleGenerateCredentialSuccess(value));
  }

  void _onResetPasswordPressed(String password) {
    final did = DID(_userInfo!.didType, _userInfo!.didValue);
    widget.client.resetPassword(did, password).then((value) {
      _handleResetPasswordSuccess(value);
    });
  }

  void _handleRegisterSuccess(RegisterResult result) {
    if (widget.onRegisterSuccess != null) {
      widget.onRegisterSuccess!(result);
    }
  }

  void _handleGenerateCredentialSuccess(User user) {
    if (widget.onGenerateCredentialSuccess != null) {
      widget.onGenerateCredentialSuccess!(user);
    }
  }

  void _handleResetPasswordSuccess(RegisterResult result) {
    if (widget.onResetPasswordSuccess != null) {
      widget.onResetPasswordSuccess!(result);
    }
  }
}

class RegisterTab extends StatelessWidget {
  final _controller = TextEditingController();

  final void Function(String) onPressed;

  RegisterTab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
          ),
          ElevatedButton(
            onPressed: () => onPressed(_controller.text),
            child: Text('Register'),
          )
        ],
      ),
    );
  }
}

class GenerateCredentialTab extends StatefulWidget {
  GenerateCredentialTab({super.key, required this.onPressed});

  final void Function(String, Duration) onPressed;

  @override
  State<GenerateCredentialTab> createState() => _GenerateCredentialState();
}

class _GenerateCredentialState extends State<GenerateCredentialTab> {
  final _controller = TextEditingController();

  Duration _duration = Duration(days: 7);

  final infiniteDuration = Duration(hours: 1000000);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
          ),
        ),
        DropdownButton<Duration>(
          value: _duration,
          onChanged: (value) {
            setState(() {
              if (null != value) {
                _duration = value;
              }
            });
          },
          items: [
            DropdownMenuItem(
              value: Duration(days: 1),
              child: Text('1 days'),
            ),
            DropdownMenuItem(
              value: Duration(days: 7),
              child: Text('7 days'),
            ),
            DropdownMenuItem(
              value: Duration(days: 14),
              child: Text('2 weeks'),
            ),
            DropdownMenuItem(
              value: Duration(days: 30),
              child: Text('1 month'),
            ),
            DropdownMenuItem(
              value: infiniteDuration,
              child: Text('no expiration'),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () => widget.onPressed(_controller.text, _duration),
          child: Text('Generate Credential'),
        ),
      ],
    ));
  }
}

class ResetPasswordTab extends StatelessWidget {
  ResetPasswordTab({super.key, required this.onPressed});

  final void Function(String) onPressed;

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'New Password',
          ),
        ),
        ElevatedButton(
          onPressed: () => onPressed(_controller.text),
          child: Text('Reset Password'),
        ),
      ],
    ));
  }
}
