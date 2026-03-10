import { Head } from '@inertiajs/react'
import EventForm from '@/components/EventForm'

type NewEventProps = {
  dress_codes: string[]
}

export default function DashboardEventsNew({ dress_codes }: NewEventProps) {
  return (
    <>
      <Head title="Create Event" />
      <div className="mx-auto max-w-3xl px-4 py-8">
        <h1 className="mb-6 text-2xl font-bold">Create Event</h1>
        <EventForm dressCodes={dress_codes} />
      </div>
    </>
  )
}
