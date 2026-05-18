// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_neverbounce_suppression.dart';

const _tracerName = 'dartastic_otel_libs_neverbounce';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class NeverbounceResult {
  const NeverbounceResult({
    this.email,
    this.result,
    this.flagsCsv,
    this.suggestedCorrection,
    this.executionTimeMs,
    this.jobId,
    this.jobStatus,
    this.jobInputCount,
    this.jobValid,
    this.jobInvalid,
    this.jobCatchall,
    this.jobDisposable,
    this.jobUnknown,
    this.creditsUsed,
    this.creditsRemaining,
    this.statusCode,
  });

  /// Validated email.
  final String? email;

  /// `valid` / `invalid` / `disposable` / `catchall` / `unknown`.
  final String? result;

  /// Comma-separated NeverBounce flags
  /// (`has_dns`, `has_dns_mx`, `bad_syntax`, `disposable_email`,
  /// `role_account`, `free_email_host`, `spelling_mistake`,
  /// `government_host`, `academic_host`, `military_host`,
  /// `international_host`, `email_temporarily_blocked`,
  /// `email_accept_all`, `smtp_connectable`, `historical_response`).
  final String? flagsCsv;

  /// Did-you-mean (e.g., `jane@gmial.com` → `jane@gmail.com`).
  final String? suggestedCorrection;

  final int? executionTimeMs;

  /// Bulk job id.
  final String? jobId;

  /// `queued` / `under_review` / `waiting_analysis` / `running` /
  /// `complete` / `failed`.
  final String? jobStatus;

  /// Job aggregate counts.
  final int? jobInputCount;
  final int? jobValid;
  final int? jobInvalid;
  final int? jobCatchall;
  final int? jobDisposable;
  final int? jobUnknown;

  final int? creditsUsed;
  final int? creditsRemaining;

  final int? statusCode;
}

class NeverbounceCallResult<T> {
  const NeverbounceCallResult({required this.value, this.result});
  final T value;
  final NeverbounceResult? result;
}

/// Wraps a NeverBounce API call in a CLIENT span. [operation] is one
/// of `single.check`, `single.search`, `jobs.create`, `jobs.search`,
/// `jobs.parse`, `jobs.start`, `jobs.status`, `jobs.results`,
/// `jobs.download`, `jobs.delete`, `poe.confirm`,
/// `account.info`.
Future<T> tracedNeverbounce<T>({
  required String operation,
  required Future<NeverbounceCallResult<T>> Function() invoke,
}) async {
  if (neverbounceInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'neverbounce',
    'rpc.method': operation,
    'neverbounce.operation': operation,
  };

  final span = _tracer().startSpan(
    'neverbounce $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.email != null) {
        extras.add(OTel.attributeString(
          'neverbounce.email',
          r.result!.email!,
        ));
      }
      if (r.result!.result != null) {
        extras.add(OTel.attributeString(
          'neverbounce.result',
          r.result!.result!,
        ));
        if (r.result!.result == 'invalid') {
          span.setStatus(
            SpanStatusCode.Error,
            'NeverBounce result invalid',
          );
        }
      }
      if (r.result!.flagsCsv != null) {
        extras.add(OTel.attributeString(
          'neverbounce.flags',
          r.result!.flagsCsv!,
        ));
      }
      if (r.result!.suggestedCorrection != null) {
        extras.add(OTel.attributeString(
          'neverbounce.suggested_correction',
          r.result!.suggestedCorrection!,
        ));
      }
      if (r.result!.executionTimeMs != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.execution_ms',
          r.result!.executionTimeMs!,
        ));
      }
      if (r.result!.jobId != null) {
        extras.add(OTel.attributeString(
          'neverbounce.job.id',
          r.result!.jobId!,
        ));
      }
      if (r.result!.jobStatus != null) {
        extras.add(OTel.attributeString(
          'neverbounce.job.status',
          r.result!.jobStatus!,
        ));
        if (r.result!.jobStatus == 'failed') {
          span.setStatus(
            SpanStatusCode.Error,
            'NeverBounce job failed',
          );
        }
      }
      if (r.result!.jobInputCount != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.job.input_count',
          r.result!.jobInputCount!,
        ));
      }
      if (r.result!.jobValid != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.job.valid',
          r.result!.jobValid!,
        ));
      }
      if (r.result!.jobInvalid != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.job.invalid',
          r.result!.jobInvalid!,
        ));
      }
      if (r.result!.jobCatchall != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.job.catchall',
          r.result!.jobCatchall!,
        ));
      }
      if (r.result!.jobDisposable != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.job.disposable',
          r.result!.jobDisposable!,
        ));
      }
      if (r.result!.jobUnknown != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.job.unknown',
          r.result!.jobUnknown!,
        ));
      }
      if (r.result!.creditsUsed != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.credits.used',
          r.result!.creditsUsed!,
        ));
      }
      if (r.result!.creditsRemaining != null) {
        extras.add(OTel.attributeInt(
          'neverbounce.credits.remaining',
          r.result!.creditsRemaining!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'NeverBounce HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
