import 'package:flashi/provider/auth_provider.dart';
import 'package:flashi/provider/token_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletHistory extends StatefulWidget {
  const WalletHistory({super.key});

  @override
  State<WalletHistory> createState() => _WalletHistoryState();
}

class _WalletHistoryState extends State<WalletHistory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> withdrawalTransactions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.delayed(Duration.zero, () {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      _fetchWithdrawalTransactions(tokenProvider, authProvider);
      _fetchTransactions(tokenProvider, authProvider);

    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions(TokenProvider tokenProvider, AuthProvider authProvider) async {
    String userId = authProvider.user_id;
    List<Map<String, dynamic>> data = await tokenProvider.getUserTransactions(userId);

    if (mounted) {
      setState(() {
        transactions = data;
      });
    }
  }

  Future<void> _fetchWithdrawalTransactions(TokenProvider tokenProvider, AuthProvider authProvider) async {
    String userId = authProvider.user_id;
    List<Map<String, dynamic>> data = await tokenProvider.getUserWithdrawalRequest(userId);

    if (mounted) {
      setState(() {
        withdrawalTransactions = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: colorScheme.onPrimary,
        foregroundColor: colorScheme.primary,
        title: Text("Wallet Transactions", style: TextStyle(color: colorScheme.primary)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: "All Transactions"),
            Tab(text: "Withdrawal History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionListView(transactions, colorScheme),
          _buildWithdrawalListView(withdrawalTransactions, colorScheme),
        ],
      ),
    );
  }

  /// All Transactions List View (Shows everything)
  Widget _buildTransactionListView(List<Map<String, dynamic>> data, ColorScheme colorScheme) {
    if (data.isEmpty) {
      return const Center(child: Text("No transactions found"));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var transaction = data[index];
        return ListTile(
          leading: Icon(Icons.account_balance_wallet, color: colorScheme.primary),
          title: Text("Amount: \$${transaction['amount']}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Type: ${transaction['transaction_type']}"),
              Text("Status: ${transaction['status']}"),
              Text("Date: ${transaction['created_at']}"),
            ],
          ),
        );
      },
    );
  }

  /// Withdrawal Transactions List View (Only Amount, Status, Requested Date)
  Widget _buildWithdrawalListView(List<Map<String, dynamic>> data, ColorScheme colorScheme) {
    if (data.isEmpty) {
      return const Center(child: Text("No withdrawal requests found"));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var transaction = data[index];
        return ListTile(
          leading: Icon(Icons.wallet_rounded, color: colorScheme.secondary),
          title: Text("Amount:\$ ${transaction['amount']}"),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Status: ${transaction['status']}"),
              Text("Requested at: ${transaction['requested_at']}"),
            ],
          ),
        );
      },
    );
  }
}
