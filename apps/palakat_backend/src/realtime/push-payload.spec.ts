import { buildPushMessage, PUSH_NOTIFICATION_BODY } from './push-payload';

/**
 * Phase 4. FCM topics are client-subscribable and no server sees the
 * subscription, so these tests are the only thing standing between a payload
 * and anyone who guesses a church id. They are written against the *fields*
 * rather than the shape on purpose: a future emitter that adds a field must
 * fail here, not ship.
 */
describe('buildPushMessage — the push allow-list', () => {
  it('carries the event and the id, and nothing else', () => {
    const msg = buildPushMessage('church.12', 'finance.updated', {
      data: { financeId: 88, churchId: 12 },
    });

    expect(msg.data).toEqual({ event: 'finance.updated', entityId: '88' });
    expect((msg as any).topic).toBe('church.12');
  });

  it.each([
    [
      'approval lifecycle',
      'approval.approved',
      {
        data: {
          entityId: 4,
          entityType: 'EXPENSE',
          entityTitle: 'Renovasi atap',
          actorName: 'Pdt. Wowor',
          resultingStatus: 'APPROVED',
          isOverride: true,
          affectedMembershipIds: [3, 9],
          churchId: 12,
        },
      },
    ],
    [
      'a whole Notification row with its Activity included',
      'notification.created',
      {
        data: {
          id: 77,
          title: 'Ibadah Keluarga',
          body: 'Rumah kel. Sondakh',
          recipient: 'membership.5',
          activity: {
            id: 4,
            name: 'Ibadah Keluarga',
            location: 'Jl. Sam Ratulangi',
          },
        },
      },
    ],
    [
      'a whole ReportJob row',
      'reportJob.updated',
      { data: { id: 3, status: 'PROCESSING', progress: 10, requestedById: 9 } },
    ],
  ])('strips %s down to event + id', (_label, event, payload) => {
    const msg = buildPushMessage('church.12', event, payload);

    expect(Object.keys(msg.data!).sort()).toEqual(['entityId', 'event']);
    // The leak this whole design exists to prevent: no field value from the
    // payload may appear anywhere in the serialized message except the id.
    const serialized = JSON.stringify(msg);
    for (const forbidden of [
      'entityTitle',
      'actorName',
      'resultingStatus',
      'affectedMembershipIds',
      'Renovasi atap',
      'Pdt. Wowor',
      'Ibadah Keluarga',
      'Sam Ratulangi',
      'requestedById',
    ]) {
      expect(serialized).not.toContain(forbidden);
    }
  });

  it('reads ids from unwrapped payloads too — the direct callers do not use {data}', () => {
    // rpc-router emits songDb.updated as a bare object, not `{ data: ... }`.
    expect(
      buildPushMessage('church.12', 'songDb.updated', {
        fileId: 5,
        sizeInKB: 900,
      }).data,
    ).toEqual({ event: 'songDb.updated', entityId: '5' });
  });

  it('omits entityId rather than inventing one when the payload has no id', () => {
    // permissions.updated carries only churchId, which is already the topic.
    expect(
      buildPushMessage('church.12', 'permissions.updated', {
        churchId: 12,
        policyUpdatedAt: null,
      }).data,
    ).toEqual({ event: 'permissions.updated' });
  });

  it.each([undefined, null, 'string', 42, {}, { data: null }])(
    'survives a malformed payload (%p)',
    (payload) => {
      expect(
        buildPushMessage('church.12', 'activity.created', payload).data,
      ).toEqual({ event: 'activity.created' });
    },
  );

  it('renders an OS notification for notification.created, with generic text', () => {
    const msg = buildPushMessage('membership.5', 'notification.created', {
      data: { id: 77, title: 'Ibadah Keluarga' },
    });

    expect(msg.notification).toEqual({
      title: 'Palakat',
      body: PUSH_NOTIFICATION_BODY,
    });
  });

  it.each(['notification.updated', 'notification.deleted'])(
    'does not draw a banner for %s — read and dismissal are not news',
    (event) => {
      const msg = buildPushMessage('membership.5', event, { data: { id: 77 } });

      expect(msg.notification).toBeUndefined();
      expect((msg as any).apns.payload.aps['content-available']).toBe(1);
    },
  );

  it('sends change signals silently, so they can only invalidate', () => {
    // §9.4: arrival must not be user-visible, or the client has a reason to
    // refetch eagerly — the fan-out the cost model depends on not happening.
    const msg = buildPushMessage('church.12', 'activity.created', {
      data: { activityId: 4 },
    });

    expect(msg.notification).toBeUndefined();
  });

  it('stringifies every data value — FCM rejects non-string data', () => {
    const msg = buildPushMessage('church.12', 'activity.created', {
      data: { activityId: 4 },
    });

    for (const value of Object.values(msg.data!)) {
      expect(typeof value).toBe('string');
    }
  });
});
