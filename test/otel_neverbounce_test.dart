// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_neverbounce/otel_neverbounce.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_neverbounce-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('single.check records result + flags + suggested correction', () async {
    await tracedNeverbounce<String>(
      operation: 'single.check',
      invoke: () async => const NeverbounceCallResult(
        value: 'ok',
        result: NeverbounceResult(
          email: 'jane@gmial.com',
          result: 'invalid',
          flagsCsv: 'spelling_mistake,bad_syntax',
          suggestedCorrection: 'jane@gmail.com',
          executionTimeMs: 180,
          creditsUsed: 1,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('neverbounce single.check')!);
    expect(a['neverbounce.result'], 'invalid');
    expect(a['neverbounce.flags'], 'spelling_mistake,bad_syntax');
    expect(a['neverbounce.suggested_correction'], 'jane@gmail.com');
    expect(
      spans.findSpanByName('neverbounce single.check')!.status,
      SpanStatusCode.Error,
    );
  });

  test('jobs.status records aggregate counts', () async {
    await tracedNeverbounce<String>(
      operation: 'jobs.status',
      invoke: () async => const NeverbounceCallResult(
        value: 'ok',
        result: NeverbounceResult(
          jobId: 'job_1',
          jobStatus: 'complete',
          jobInputCount: 50000,
          jobValid: 41200,
          jobInvalid: 6500,
          jobCatchall: 1800,
          jobDisposable: 350,
          jobUnknown: 150,
          creditsUsed: 50000,
          creditsRemaining: 250000,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('neverbounce jobs.status')!);
    expect(a['neverbounce.job.status'], 'complete');
    expect(a['neverbounce.job.input_count'], 50000);
    expect(a['neverbounce.job.valid'], 41200);
    expect(a['neverbounce.job.invalid'], 6500);
    expect(a['neverbounce.credits.used'], 50000);
  });

  test('failed job sets span error', () async {
    await tracedNeverbounce<String>(
      operation: 'jobs.status',
      invoke: () async => const NeverbounceCallResult(
        value: 'ok',
        result: NeverbounceResult(
          jobId: 'job_2',
          jobStatus: 'failed',
        ),
      ),
    );
    expect(
      spans.findSpanByName('neverbounce jobs.status')!.status,
      SpanStatusCode.Error,
    );
  });

  test('catchall does NOT set span error', () async {
    await tracedNeverbounce<String>(
      operation: 'single.check',
      invoke: () async => const NeverbounceCallResult(
        value: 'ok',
        result: NeverbounceResult(result: 'catchall'),
      ),
    );
    expect(
      spans.findSpanByName('neverbounce single.check')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutNeverbounceInstrumentationAsync(() async {
      await tracedNeverbounce<String>(
        operation: 'account.info',
        invoke: () async => const NeverbounceCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('neverbounce '), isEmpty);
  });
}
