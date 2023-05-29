import 'package:flutter/material.dart';
import 'package:web3mq/src/api/responses.dart';
import 'package:web3mq/src/client/client.dart';
import 'package:web3mq/src/models/accounts.dart';

enum AccountEvent {
  registerSuccess,
  generateCredentialSuccess,
  resetPasswordSuccess
}

/// An account modal, for user register, login, password reset.
class AccountModal extends StatefulWidget {
  ///
  AccountModal({super.key, this.onEvent, required this.client});

  final Web3MQClient client;

  ///
  final void Function(AccountEvent)? onEvent;

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
        // 如果没有连接钱包，展示一个连接按钮，连接完之后展示基本的用户信息，然后由3个基本功能，注册，创建登录凭证，重置密码，这三个功能可以通过一个顶部的 tab 切换，结果通过 event 传递给外界
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
                        RegisterTab(onSuccess: _handleRegisterSuccess),
                        GenerateCredentialTab(
                            onSuccess: _handleGenerateCredentialSuccess),
                        ResetPasswordTab(
                            onSuccess: _handleResetPasswordSuccess),
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

  void _handleRegisterSuccess() {
    if (widget.onEvent != null) {
      widget.onEvent!(AccountEvent.registerSuccess);
    }
  }

  void _handleGenerateCredentialSuccess() {
    if (widget.onEvent != null) {
      widget.onEvent!(AccountEvent.generateCredentialSuccess);
    }
  }

  void _handleResetPasswordSuccess() {
    if (widget.onEvent != null) {
      widget.onEvent!(AccountEvent.resetPasswordSuccess);
    }
  }
}

class RegisterTab extends StatelessWidget {
  RegisterTab({super.key, required this.onSuccess});

  final void Function() onSuccess;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Perform registration logic here
          onSuccess.call();
        },
        child: Text('Register'),
      ),
    );
  }
}

class GenerateCredentialTab extends StatelessWidget {
  GenerateCredentialTab({super.key, required this.onSuccess});

  final void Function() onSuccess;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Perform generate credential logic here
          onSuccess.call();
        },
        child: Text('Generate Credential'),
      ),
    );
  }
}

class ResetPasswordTab extends StatelessWidget {
  ResetPasswordTab({super.key, required this.onSuccess});

  final void Function() onSuccess;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Perform reset password logic here
          onSuccess.call();
        },
        child: Text('Reset Password'),
      ),
    );
  }
}
