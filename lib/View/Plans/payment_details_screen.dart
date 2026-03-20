import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/payment_history_model.dart';
import '../../services/payment_history_api_service.dart';
import '../../services/invoice_download_service.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String orderId;
  final PaymentHistory? initialPayment;

  const PaymentDetailsScreen({
    super.key,
    required this.orderId,
    this.initialPayment,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  PaymentHistory? _paymentDetails;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPayment != null) {
      _paymentDetails = widget.initialPayment;
    } else {
      _fetchPaymentDetails();
    }
  }

  Future<void> _fetchPaymentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await PaymentHistoryApiService.fetchPaymentDetails(widget.orderId);
      
      if (response['success'] == true && response['payment'] != null) {
        setState(() {
          _paymentDetails = PaymentHistory.fromJson(response['payment']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to fetch payment details';
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Payment details fetch error: $e");
      setState(() {
        _errorMessage = 'Unable to load payment details. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadInvoice() async {
    final paymentId = _paymentDetails?.paymentId;
    if (paymentId == null) return;

    setState(() => _isDownloading = true);

    try {
      final filePath = await InvoiceDownloadService.downloadInvoice(paymentId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invoice downloaded to Downloads folder'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () => InvoiceDownloadService.openFile(filePath),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to download invoice. Please try again.'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Payment Details',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Payment Details',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchPaymentDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_paymentDetails == null) {
      return const Center(
        child: Text('No payment details found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 20),
          _buildPaymentInfoCard(),
          const SizedBox(height: 20),
          _buildOrderInfoCard(),
          const SizedBox(height: 20),
          _buildValidityCard(),
          if (_paymentDetails?.paymentId != null) ...[
            const SizedBox(height: 24),
            _buildDownloadButton(),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final payment = _paymentDetails!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            payment.statusColor.withOpacity(0.1),
            payment.statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: payment.statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: payment.statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              payment.status.toUpperCase(),
              style: AppTextStyles.subtitle1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            payment.formattedAmount,
            style: AppTextStyles.h1.copyWith(
              color: payment.statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${payment.formattedDate} at ${payment.formattedTime}',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    final payment = _paymentDetails!;
    
    return _buildInfoCard(
      title: 'Payment Information',
      icon: Icons.payment,
      children: [
        if (payment.paymentId != null)
          _buildInfoRow(
            'Payment ID',
            payment.paymentId!,
            copyable: true,
          ),
        _buildInfoRow(
          'Amount',
          payment.formattedAmount,
        ),
        if (payment.signature != null)
          _buildInfoRow(
            'Signature',
            payment.signature!,
            copyable: true,
            truncate: true,
          ),
        _buildInfoRow(
          'Receipt',
          payment.receipt,
          copyable: true,
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    final payment = _paymentDetails!;
    
    return _buildInfoCard(
      title: 'Order Information',
      icon: Icons.receipt_long,
      children: [
        _buildInfoRow(
          'Order ID',
          payment.orderId,
          copyable: true,
        ),
        _buildInfoRow(
          'User ID',
          payment.userId,
          copyable: true,
        ),
        _buildInfoRow(
          'Plan ID',
          payment.planId,
          copyable: true,
        ),
        _buildInfoRow(
          'Created At',
          '${payment.formattedDate} ${payment.formattedTime}',
        ),
        _buildInfoRow(
          'Updated At',
          payment.formattedUpdatedDateTime,
        ),
      ],
    );
  }

  Widget _buildValidityCard() {
    final payment = _paymentDetails!;
    
    if (payment.validFrom == null || payment.validUntil == null) {
      return const SizedBox.shrink();
    }
    
    return _buildInfoCard(
      title: 'Plan Validity',
      icon: Icons.schedule,
      children: [
        _buildInfoRow(
          'Valid From',
          '${payment.validFrom!.day}/${payment.validFrom!.month}/${payment.validFrom!.year}',
        ),
        _buildInfoRow(
          'Valid Until',
          '${payment.validUntil!.day}/${payment.validUntil!.month}/${payment.validUntil!.year}',
        ),
        _buildInfoRow(
          'Duration',
          '${payment.validUntil!.difference(payment.validFrom!).inDays} days',
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isDownloading ? null : _downloadInvoice,
        icon: _isDownloading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.download_rounded, size: 20),
        label: Text(_isDownloading ? 'Downloading...' : 'Download Invoice'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool copyable = false,
    bool truncate = false,
  }) {
    String displayValue = value;
    if (truncate && value.length > 20) {
      displayValue = '${value.substring(0, 20)}...';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayValue,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyToClipboard(value, label),
                    child: Icon(
                      Icons.copy,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}