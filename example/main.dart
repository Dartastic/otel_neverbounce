// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_neverbounce/otel_neverbounce.dart';

/// Traces NeverBounce calls with OpenTelemetry.
///
/// `otel_neverbounce` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each NeverBounce call in
/// [tracedNeverbounce]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'neverbounce-example');

  // Wraps a NeverBounce API call in a CLIENT span.
  final neverbounceId = await tracedNeverbounce<String>(
    operation: 'jobs.create',
    invoke: () async {
      // Make the NeverBounce call here, then report what it returned.
      const id = 'neverbounce_8f3a2c';
      return const NeverbounceCallResult(
          value: id,
          result: NeverbounceResult(
              email: 'ada@example.com',
              result: 'valid',
              flagsCsv: 'has_dns',
              suggestedCorrection: 'jane@gmial.com',
              executionTimeMs: 120,
              jobId: 'job_8f3a2c',
              jobStatus: 'queued',
              jobInputCount: 3,
              jobValid: 1,
              jobInvalid: 1,
              jobCatchall: 1,
              jobDisposable: 1,
              jobUnknown: 1,
              creditsUsed: 1,
              creditsRemaining: 1,
              statusCode: 201));
    },
  );
  OTelLog.info('tracedNeverbounce jobs.create returned $neverbounceId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutNeverbounceInstrumentationAsync.
  await runWithoutNeverbounceInstrumentationAsync(
    () => tracedNeverbounce<String>(
      operation: 'jobs.create',
      invoke: () async {
        const id = 'neverbounce_8f3a2c';
        return const NeverbounceCallResult(
            value: id,
            result: NeverbounceResult(
                email: 'ada@example.com',
                result: 'valid',
                flagsCsv: 'has_dns',
                suggestedCorrection: 'jane@gmial.com',
                executionTimeMs: 120,
                jobId: 'job_8f3a2c',
                jobStatus: 'queued',
                jobInputCount: 3,
                jobValid: 1,
                jobInvalid: 1,
                jobCatchall: 1,
                jobDisposable: 1,
                jobUnknown: 1,
                creditsUsed: 1,
                creditsRemaining: 1,
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
