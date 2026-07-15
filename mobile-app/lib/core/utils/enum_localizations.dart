import '../localization/generated/app_localizations.dart';
import '../../data/models/enums.dart';

extension BookingStatusL10n on BookingStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BookingStatus.confirmed:
        return l10n.myBookingsStatusConfirmed;
      case BookingStatus.waitlisted:
        return l10n.myBookingsStatusWaitlisted;
      case BookingStatus.cancelled:
        return l10n.myBookingsStatusCancelled;
      case BookingStatus.completed:
        return l10n.myBookingsStatusCompleted;
    }
  }
}

extension PaymentStatusL10n on PaymentStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PaymentStatus.succeeded:
        return l10n.paymentStatusSucceeded;
      case PaymentStatus.pending:
        return l10n.paymentStatusPending;
      case PaymentStatus.failed:
        return l10n.paymentStatusFailed;
      case PaymentStatus.refunded:
        return l10n.paymentStatusRefunded;
    }
  }
}

extension PaymentMethodL10n on PaymentMethod {
  String label(AppLocalizations l10n) {
    switch (this) {
      case PaymentMethod.mada:
        return l10n.checkoutMethodMada;
      case PaymentMethod.applePay:
        return l10n.checkoutMethodApplePay;
      case PaymentMethod.stcPay:
        return l10n.checkoutMethodStcPay;
      case PaymentMethod.creditCard:
        return l10n.checkoutMethodCreditCard;
    }
  }
}
