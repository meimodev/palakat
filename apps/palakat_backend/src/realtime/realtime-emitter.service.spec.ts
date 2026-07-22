import { Test, TestingModule } from '@nestjs/testing';
import { RealtimeEmitterService } from './realtime-emitter.service';
import { RealtimeGateway } from './realtime.gateway';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';

/**
 * Phase 4. The first version of `emitToRoom` swapped the socket for FCM and
 * dropped the socket emit — which would have killed live updates in
 * `palakat_admin` the next time anyone tagged a backend deploy, because
 * **nothing in the repo calls `subscribeToTopic`**. Seven files there consume
 * `realtimeEventProvider`, and it has served production since 2026-03-20.
 *
 * Nothing failed when that happened: the backend published happily to topics
 * with no subscribers, and the only symptom would have been an admin screen
 * that quietly stopped updating. These tests are the alarm that was missing.
 */
describe('RealtimeEmitterService — transport', () => {
  let service: RealtimeEmitterService;

  const emit = jest.fn();
  const to = jest.fn(() => ({ emit }));
  const send = jest.fn().mockResolvedValue('ok');

  const gateway = { server: { to } } as unknown as RealtimeGateway;
  const firebase = {
    messaging: () => ({ send }),
  } as unknown as FirebaseAdminService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RealtimeEmitterService,
        { provide: RealtimeGateway, useValue: gateway },
        { provide: FirebaseAdminService, useValue: firebase },
      ],
    }).compile();
    service = module.get(RealtimeEmitterService);
    jest.clearAllMocks();
  });

  it('emits on BOTH transports while no client subscribes to topics', () => {
    service.emitToRoom('church.12', 'activity.created', {
      data: { activityId: 4, activityTitle: 'Ibadah' },
    });

    expect(send).toHaveBeenCalledTimes(1);
    expect(to).toHaveBeenCalledWith('church.12');
    expect(emit).toHaveBeenCalledTimes(1);
  });

  it('strips content from the push but not from the socket', () => {
    // The socket is authenticated and room-authorized (#56), so it keeps the
    // posture these payloads already had. The topic is not, so it does not.
    service.emitToRoom('church.12', 'approval.approved', {
      data: {
        entityId: 4,
        entityTitle: 'Renovasi atap',
        actorName: 'Pdt. Wowor',
      },
    });

    expect(send.mock.calls[0][0].data).toEqual({
      event: 'approval.approved',
      entityId: '4',
    });
    expect(JSON.stringify(send.mock.calls[0][0])).not.toContain(
      'Renovasi atap',
    );

    expect(emit.mock.calls[0][1].data.entityTitle).toBe('Renovasi atap');
  });

  it('keeps report progress off FCM entirely', () => {
    // §9.3: best-effort delivery is wrong for a progress bar, and these carry
    // whole rows the allow-list would flatten to an id.
    service.emitToSocketRoom('account.9', 'reportJob.updated', {
      data: { id: 3, progress: 10 },
    });

    expect(send).not.toHaveBeenCalled();
    expect(emit).toHaveBeenCalledTimes(1);
  });

  it('does not let a failed push take down the socket emit, or the caller', async () => {
    send.mockRejectedValueOnce(new Error('FCM unavailable'));

    expect(() =>
      service.emitToRoom('church.12', 'activity.created', {
        data: { activityId: 4 },
      }),
    ).not.toThrow();

    expect(emit).toHaveBeenCalledTimes(1);
    await new Promise(process.nextTick); // let the rejection settle unhandled-free
  });

  it('survives the socket server not being ready', () => {
    const detached = new RealtimeEmitterService(
      { server: undefined } as unknown as RealtimeGateway,
      firebase,
    );

    expect(() =>
      detached.emitToRoom('church.12', 'activity.created', {
        data: { activityId: 4 },
      }),
    ).not.toThrow();
    expect(send).toHaveBeenCalledTimes(1);
  });

  it.each(['', '   '])(
    'ignores a blank room (%p) on both transports',
    (room) => {
      service.emitToRoom(room, 'activity.created', { data: { activityId: 4 } });

      expect(send).not.toHaveBeenCalled();
      expect(emit).not.toHaveBeenCalled();
    },
  );
});
