# Email-Based Meeting Scheduling Assistant

## 1. Summary
A scheduling assistant that joins email threads and handles the back-and-forth required to book meetings without forcing participants into a separate scheduling link flow.

## 2. Problem Statement
Scheduling links are efficient but often feel impersonal and disruptive in natural email conversations. Users want a way to coordinate meetings inside email without manually negotiating availability across participants and time zones.

## 3. Users and Stakeholders
### Primary users
- Founders
- Operators
- Busy professionals who schedule frequent meetings

### Secondary users / stakeholders
- Invitees participating in scheduling threads
- Product/business stakeholders responsible for trust, privacy, and retention

## 4. Goals
- Reduce manual scheduling back-and-forth in email
- Preserve the natural email workflow
- Support reliable scheduling across time zones

## 5. Success Criteria
- Users can successfully book meetings by adding the assistant to an email thread
- Time zone conflicts are handled correctly
- Scheduling can be completed without users leaving email
- Privacy concerns are reduced through minimal storage of message content

## 6. Functional Requirements
1. The assistant must detect scheduling intent from an email thread it is included in.
2. The assistant must propose available times based on the organiser’s calendar.
3. The assistant must support one-to-one and small multi-party scheduling.
4. The assistant must confirm the selected slot and create the calendar event.
5. The assistant must support Google Calendar in MVP.

## 7. Non-Functional Requirements
1. The system should minimise storage of email message bodies.
2. The system must handle time zones correctly.
3. The system should provide clear and trustworthy email communication.
4. The system should fail gracefully if calendar access is unavailable or insufficient.

## 8. Constraints
- MVP should prioritise Google Calendar support
- Privacy expectations are high
- Multi-party scheduling is required early

## 9. Assumptions
- Users are willing to grant calendar access
- Scheduling can be inferred with reasonable accuracy from email content
- Limiting storage of message bodies is technically feasible

## 10. In Scope
- Email-based scheduling assistant flow
- Google Calendar integration
- Multi-party scheduling for small groups
- Time zone handling
- Privacy-aware processing

## 11. Out of Scope
- Microsoft Calendar support in MVP
- Restaurant or venue booking
- Long-term memory of user preferences
- Automatic follow-ups beyond scheduling

## 12. Future Considerations
- Microsoft support
- multilingual scheduling
- preference memory
- in-person meeting logistics

## 13. Open Questions
- What minimum calendar permissions are required?
- How should conflicting participant preferences be resolved?
- What level of AI transparency is needed to build trust?
- How should scheduling failures be explained in-thread?

## 14. Notes from Source Material
- Users dislike Calendly-style context switching
- Privacy is a core concern
- Trust may be a major adoption factor