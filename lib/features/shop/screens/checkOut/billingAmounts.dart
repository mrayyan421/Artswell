import 'package:flutter/material.dart';

class kBillingAmounts extends StatefulWidget {
  final double totalAmount;
  final double shippingFee;
  final double shopCharges;
  final ValueChanged<double> onGrandTotalCalculated;

  const kBillingAmounts({
    super.key,
    this.shippingFee = 150,
    this.shopCharges = 250,
    required this.totalAmount,
    required this.onGrandTotalCalculated,
  });

  @override
  State<kBillingAmounts> createState() => _kBillingAmountsState();
}

class _kBillingAmountsState extends State<kBillingAmounts> {
  late double _grandTotal;

  @override
  void initState() {
    super.initState();
    _calculateGrandTotal();
  }

  @override
  void didUpdateWidget(covariant kBillingAmounts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalAmount != widget.totalAmount ||
        oldWidget.shippingFee != widget.shippingFee ||
        oldWidget.shopCharges != widget.shopCharges) {
      _calculateGrandTotal();
    }
  }

  void _calculateGrandTotal() {
    _grandTotal = widget.totalAmount + widget.shippingFee + widget.shopCharges;
    widget.onGrandTotalCalculated(_grandTotal);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAmountRow(
          label: 'Subtotal:',
          amount: widget.totalAmount,
          context: context,
        ),
        _buildAmountRow(
          label: 'Shipping Fee:',
          amount: widget.shippingFee,
          context: context,
          isSecondary: true,
        ),
        _buildAmountRow(
          label: 'Shop Charges:',
          amount: widget.shopCharges,
          context: context,
          isSecondary: true,
        ),
        const Divider(),
        _buildAmountRow(
          label: 'Grand Total:',
          amount: _grandTotal,
          context: context,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildAmountRow({
    required String label,
    required double amount,
    required BuildContext context,
    bool isSecondary = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'PKR ${amount.toStringAsFixed(2)}',
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            )
                : isSecondary
                ? Theme.of(context).textTheme.bodySmall
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}