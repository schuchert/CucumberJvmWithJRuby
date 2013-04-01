require 'java'

java_import 'org.hamcrest.CoreMatchers'
java_import 'org.junit.Assert'
java_import 'shoe.example.schedule.BusinessDateTimeFactory'

$CLASSPATH << "target/classes"

sse = nil

Given /^an empty schedule$/ do
  sse = Java::ShoeExampleSchedule::ScheduleSystemExample.new
end

Given /^a work item named (\w+) scheduled to start at (\d+):(\d+), last for (\d+) minutes, and use (\w+)$/ do |workItemName, hour, minute, durationInMinutes, resourceName|
  time = BusinessDateTimeFactory.todayAt(hour.to_i, minute.to_i)
  sse.scheduleNewWorkItem(workItemName, time, durationInMinutes.to_i, resourceName)
end

def set_time_to(sse, hour, minute)
  BusinessDateTimeFactory.setTimeTo(hour, minute)
  sse.recalculate
end

def move_time_forward_to(sse, hour, minute)
  currentTime = BusinessDateTimeFactory.now
  endTime = BusinessDateTimeFactory.todayAt(hour.to_i, minute.to_i)

  while endTime.isAfter(currentTime)
    currentTime = currentTime.plusMinutes(1)
    set_time_to(sse, currentTime.getHourOfDay, currentTime.getMinuteOfHour)
  end
end

def state_for(stateName)
  case stateName
    when 'active'
      return Java::ShoeExampleSchedule::Active
    when 'pending'
      return Java::ShoeExampleSchedule::Pending
    when 'blocked'
      return Java::ShoeExampleSchedule::Blocked
    when 'completed'
      return Java::ShoeExampleSchedule::Completed
    when 'unscheduled'
      return Java::ShoeExampleSchedule::Unsheduled
    when 'active'
      return Java::ShoeExampleSchedule::ActiveActive
    else
      raise 'Unhandled state: ' + stateName
  end
end

Given /^a first one wins conflict resolution approach$/ do
  sse.setConflictResolutionTo(Java::ShoeExampleSchedule::FirstOneWins.new)
end

Given /^the business time is (\d+):(\d+)$/ do |hour, minute|
  set_time_to(sse, hour.to_i, minute.to_i)
end

Then /^there should be no active items at (\d+):(\d+)$/ do |hour, minute|
  move_time_forward_to(sse, hour.to_i, minute.to_i)
  Assert.assertEquals(sse.workItemsIn(Java::ShoeExampleSchedule::Active).size(), 0)
end

Then /^(\w+) should be (\w+)$/ do |workItemName, workItemState|
  Assert.assertTrue(sse.workItemIs(workItemName,state_for(workItemState)))
end

Then /^(\w+) should be (\w+) at (\d+):(\d+)$/ do |workItemName, workItemState, hour, minute|
  move_time_forward_to(sse, hour.to_i, minute.to_i)
  Assert.assertTrue(sse.workItemIs(workItemName,state_for(workItemState)))
end
