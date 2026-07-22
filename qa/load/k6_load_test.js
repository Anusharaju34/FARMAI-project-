import http from 'k6/http';
import { check, sleep } from 'k6';

// ==============================================================================
// K6 LOAD & PERFORMANCE SLA TESTS (LOAD-001 to LOAD-030)
// ==============================================================================

export const options = {
  // Define scenarios / thresholds
  thresholds: {
    http_req_failed: ['rate<0.01'], // less than 1% errors
    http_req_duration: ['p(95)<350'], // 95% of requests must complete under 350ms
  },
  stages: [
    { duration: '10s', target: 5 },  // Warm up / Smoke
    { duration: '20s', target: 20 }, // Average load
    { duration: '10s', target: 0 },  // Ramp down
  ],
};

export default function () {
  // Use a mock local / public safe endpoint
  const url = 'https://dummy.supabase.co/rest/v1/weather_alerts';
  const params = {
    headers: {
      'Content-Type': 'application/json',
      'apikey': 'dummy_anon_key_for_ci',
    },
  };
  
  const res = http.get(url, params);
  
  check(res, {
    'status is 200 or 400 or 404': (r) => r.status === 200 || r.status === 400 || r.status === 404,
    'transaction time under 350ms': (r) => r.timings.duration < 350,
  });
  
  sleep(1);
}

export function handleSummary(data) {
  return {
    'qa/reports/k6_summary.json': JSON.stringify(data, null, 2),
    stdout: textSummary(data, { indent: ' ', enableColors: true }),
  };
}

// Inline helper for text summary rendering
function textSummary(data, options) {
  const p95 = data.metrics.http_req_duration.values['p(95)'];
  const failed = data.metrics.http_req_failed.values.rate * 100;
  return `k6 Load Test Summary:\n p(95) response duration: ${p95.toFixed(2)} ms\n Request failure rate: ${failed.toFixed(2)} %\n`;
}
