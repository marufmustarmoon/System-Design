# Schedule-Driven — বাংলা ব্যাখ্যা

_টপিক নম্বর: 027_

## গল্পে বুঝি

মন্টু মিয়াঁর কিছু কাজ user request-এ না, সময়মতো করতে হয় - nightly cleanup, billing batch, report generation, periodic sync।

`Schedule-Driven` টপিকটা time-based triggering model নিয়ে, যেখানে schedule, execution reliability, retry, duplicate prevention গুরুত্বপূর্ণ।

শুধু cron দিলেই production-ready হয় না; job overlap, missed runs, worker crash, clock skew, and monitoring plan দরকার।

বিশেষ করে distributed scheduler হলে lease/heartbeat/idempotency critical হয়ে যায়।

সহজ করে বললে `Schedule-Driven` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Schedule-driven jobs run at fixed times or intervals (cron-style), regardless of incoming user events।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `Schedule-Driven`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Schedule-Driven` আসলে কীভাবে সাহায্য করে?

`Schedule-Driven` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Schedule-Driven` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Periodic maintenance, compaction, cleanup, reports.
- Business value কোথায় বেশি? → Some tasks হলো periodic by nature: backups, cleanup, aggregation, billing cycles, ক্যাশ warm-up.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: রিয়েল-টাইম workflows যেখানে ইউজাররা expect immediate action.
- ইন্টারভিউ রেড ফ্ল্যাগ: ব্যবহার করে cron জন্য near-রিয়েল-টাইম processing যখন ইভেন্টগুলো হলো the natural trigger.
- না considering time zones এবং daylight saving behavior.
- Letting all jobs fire at the same minute এবং overload dependencies.
- Assuming a cron entry equals reliable distributed scheduling.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Schedule-Driven` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: schedule definition ও timezone/window policy ঠিক করুন।
- ধাপ ২: job trigger durableভাবে record করুন।
- ধাপ ৩: worker crash হলে retry/reschedule mechanism দিন।
- ধাপ ৪: duplicate run prevent করতে idempotency/lock ব্যবহার করুন।
- ধাপ ৫: missed run alerting/monitoring রাখুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?
- consumer slow হলে back pressure/DLQ/retry policy কীভাবে কাজ করবে?

---

## এক লাইনে

- `Schedule-Driven` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: delivery semantics, retry policy, idempotency, ordering, DLQ/back pressure

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Schedule-Driven` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- শিডিউল-ড্রিভেন jobs run at fixed times অথবা intervals (cron-style), regardless of incoming ইউজার ইভেন্টগুলো.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- Some tasks হলো periodic by nature: backups, cleanup, aggregation, billing cycles, ক্যাশ warm-up.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- একটি scheduler triggers tasks based on time expressions; workers execute them.
- Idempotency matters কারণ jobs may overlap, run late, অথবা হতে retried পরে partial ফেইলিউর.
- Compared সাথে ইভেন্ট-ড্রিভেন jobs, শিডিউল-ড্রিভেন jobs হলো simpler জন্য periodic কাজ but less reactive এবং পারে create bursty লোড.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Schedule-Driven` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** পারে run scheduled aggregation jobs জন্য usage analytics এবং billing/reporting pipelines.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Schedule-Driven` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Periodic maintenance, compaction, cleanup, reports.
- কখন ব্যবহার করবেন না: রিয়েল-টাইম workflows যেখানে ইউজাররা expect immediate action.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How do আপনি রোধ করতে duplicate execution যখন the scheduler restarts?\"
- রেড ফ্ল্যাগ: ব্যবহার করে cron জন্য near-রিয়েল-টাইম processing যখন ইভেন্টগুলো হলো the natural trigger.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Schedule-Driven`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- না considering time zones এবং daylight saving behavior.
- Letting all jobs fire at the same minute এবং overload dependencies.
- Assuming a cron entry equals reliable distributed scheduling.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: ব্যবহার করে cron জন্য near-রিয়েল-টাইম processing যখন ইভেন্টগুলো হলো the natural trigger.
- কমন ভুল এড়ান: না considering time zones এবং daylight saving behavior.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Some tasks হলো periodic by nature: backups, cleanup, aggregation, billing cycles, ক্যাশ warm-up.
