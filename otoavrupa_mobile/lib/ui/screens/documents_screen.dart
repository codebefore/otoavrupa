import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/vehicle.dart';
import '../../models/document.dart';

class DocumentsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const DocumentsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // TODO: Replace with actual data from API
  final List<Document> _dummyDocuments = [];

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Dummy data for UI testing
    _dummyDocuments.addAll([
      Document(
        id: 1,
        vehicleId: widget.vehicle.id.toString(),
        serviceRecordId: 1,
        documentType: 'service_receipt',
        title: AppStrings.serviceReceipt,
        fileUrl: 'https://example.com/receipt.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Document(
        id: 2,
        vehicleId: widget.vehicle.id.toString(),
        serviceRecordId: 1,
        documentType: 'invoice',
        title: AppStrings.invoice,
        fileUrl: 'https://example.com/invoice.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.documents),
      ),
      body: _dummyDocuments.isEmpty
          ? _buildEmptyWidget()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _dummyDocuments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final document = _dummyDocuments[index];
                return _buildDocumentCard(document);
              },
            ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _viewDocument(document),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // File Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getDocumentColor(document).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDocumentIcon(document),
                  size: 28,
                  color: _getDocumentColor(document),
                ),
              ),

              const SizedBox(width: 16),

              // Document Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.formattedDate,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              // View Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 64,
            color: AppTheme.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noData,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belge bulunamadı',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Color _getDocumentColor(Document document) {
    if (document.isServiceReceipt) {
      return AppTheme.primaryColor;
    } else if (document.isInvoice) {
      return AppTheme.success;
    }
    return AppTheme.gray600;
  }

  IconData _getDocumentIcon(Document document) {
    if (document.isServiceReceipt) {
      return Icons.receipt_long;
    } else if (document.isInvoice) {
      return Icons.request_quote;
    }
    return Icons.description;
  }

  void _viewDocument(Document document) {
    // TODO: Implement PDF viewing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${document.title} görüntüleniyor...'),
        backgroundColor: AppTheme.primaryColor,
        action: SnackBarAction(
          label: 'Kapat',
          textColor: AppTheme.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
