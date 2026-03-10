import { Head } from '@inertiajs/react'
import EventForm from '@/components/EventForm'
import type { Event } from '@/types'

type EditEventProps = {
  event: Event
  dress_codes: string[]
}

export default function DashboardEventsEdit({
  event,
  dress_codes,
}: EditEventProps) {
  return (
    <>
      <Head title="Edit Event" />
      <div className="mx-auto max-w-3xl px-4 py-8">
        <h1 className="mb-6 text-2xl font-bold">Edit Event</h1>
        <EventForm event={event} dressCodes={dress_codes} />
      </div>
    </>
  )
}
