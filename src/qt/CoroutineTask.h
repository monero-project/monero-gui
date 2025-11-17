// Copyright (c) 2024, The Monero Project
//
// C++23 coroutine support for async operations
// This provides a modern coroutine-based alternative to QtConcurrent for async tasks

#pragma once

#include <coroutine>
#include <exception>
#include <memory>
#include <optional>
#include <type_traits>

// C++23: Simple coroutine task type for async operations
template<typename T>
class Task {
public:
    struct promise_type {
        std::optional<T> value;
        std::exception_ptr exception;

        Task get_return_object() {
            return Task{std::coroutine_handle<promise_type>::from_promise(*this)};
        }

        std::suspend_never initial_suspend() { return {}; }
        std::suspend_always final_suspend() noexcept { return {}; }

        void unhandled_exception() {
            exception = std::current_exception();
        }

        void return_value(T val) {
            value = std::move(val);
        }
    };

    Task(std::coroutine_handle<promise_type> handle) : handle_(handle) {}

    ~Task() {
        if (handle_) {
            handle_.destroy();
        }
    }

    // Non-copyable
    Task(const Task&) = delete;
    Task& operator=(const Task&) = delete;

    // Movable
    Task(Task&& other) noexcept : handle_(other.handle_) {
        other.handle_ = {};
    }

    Task& operator=(Task&& other) noexcept {
        if (this != &other) {
            if (handle_) {
                handle_.destroy();
            }
            handle_ = other.handle_;
            other.handle_ = {};
        }
        return *this;
    }

    bool await_ready() const noexcept {
        return !handle_ || handle_.done();
    }

    void await_suspend(std::coroutine_handle<> awaiting) {
        // Resume the awaiting coroutine when this task completes
        handle_.resume();
        awaiting.resume();
    }

    T await_resume() {
        if (handle_.promise().exception) {
            std::rethrow_exception(handle_.promise().exception);
        }
        return std::move(*handle_.promise().value);
    }

    bool done() const {
        return handle_ && handle_.done();
    }

    T get() {
        if (!handle_) {
            throw std::runtime_error("Task is empty");
        }
        if (!handle_.done()) {
            handle_.resume();
        }
        if (handle_.promise().exception) {
            std::rethrow_exception(handle_.promise().exception);
        }
        return std::move(*handle_.promise().value);
    }

private:
    std::coroutine_handle<promise_type> handle_;
};

// Specialization for void
template<>
class Task<void> {
public:
    struct promise_type {
        std::exception_ptr exception;

        Task get_return_object() {
            return Task{std::coroutine_handle<promise_type>::from_promise(*this)};
        }

        std::suspend_never initial_suspend() { return {}; }
        std::suspend_always final_suspend() noexcept { return {}; }

        void unhandled_exception() {
            exception = std::current_exception();
        }

        void return_void() {}
    };

    Task(std::coroutine_handle<promise_type> handle) : handle_(handle) {}

    ~Task() {
        if (handle_) {
            handle_.destroy();
        }
    }

    Task(const Task&) = delete;
    Task& operator=(const Task&) = delete;

    Task(Task&& other) noexcept : handle_(other.handle_) {
        other.handle_ = {};
    }

    Task& operator=(Task&& other) noexcept {
        if (this != &other) {
            if (handle_) {
                handle_.destroy();
            }
            handle_ = other.handle_;
            other.handle_ = {};
        }
        return *this;
    }

    bool await_ready() const noexcept {
        return !handle_ || handle_.done();
    }

    void await_suspend(std::coroutine_handle<> awaiting) {
        handle_.resume();
        awaiting.resume();
    }

    void await_resume() {
        if (handle_.promise().exception) {
            std::rethrow_exception(handle_.promise().exception);
        }
    }

    bool done() const {
        return handle_ && handle_.done();
    }

    void get() {
        if (!handle_) {
            throw std::runtime_error("Task is empty");
        }
        if (!handle_.done()) {
            handle_.resume();
        }
        if (handle_.promise().exception) {
            std::rethrow_exception(handle_.promise().exception);
        }
    }

private:
    std::coroutine_handle<promise_type> handle_;
};

// Example usage:
// Task<std::string> fetchData() {
//     co_return "data";
// }
//
// Task<void> processData() {
//     auto data = co_await fetchData();
//     // process data
// }

