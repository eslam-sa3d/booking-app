import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

/**
 * TODO(next phase): implement once a payment gateway (Moyasar/HyperPay/
 * Stripe) is chosen — see mobile-app's PaymentService interface for the
 * client-side half of this contract.
 *
 * Will: verify the gateway's webhook signature, look up the pending
 * `transactions/{id}` by gateway reference, mark it succeeded/failed, and
 * on success call the same "grant package" logic the client-triggered
 * purchase flow uses today (packages/purchase Cloud Function, also
 * TODO'd for next phase — currently the mobile app's mock PaymentService
 * grants packages client-side).
 */
export const paymentWebhook = onRequest((request, response) => {
  logger.warn("paymentWebhook called but not yet implemented", { body: request.body });
  response.status(501).json({ error: "Payment webhook not implemented yet." });
});
