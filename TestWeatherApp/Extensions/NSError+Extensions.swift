//
//  NSError+Extensions.swift
//  TestWeatherApp
//
//  Created by user on 13.05.2025.
//

import Foundation
import Alamofire

extension NSError {
    /// Ошибка `Отмена`.
    var isCancelled: Bool {
        return self.code == NSURLErrorCancelled
    }
    /// Создание ошибки типа `Отмена`.
    static func cancelledError(reason: String) -> NSError {
        return NSError(code: NSURLErrorCancelled, reason: reason)
    }
    /// Конструктор для создания ошибки. Передаётся код при причина.
    convenience init(code: Int, reason: String) {
        self.init(domain: "WeatherAppErrorDomain", code: code, userInfo: [NSLocalizedDescriptionKey: reason])
    }
    /// Создание ошибки из ошибки Alamofire.
    static func initFrom(afError: AFError) -> NSError {
        let nsError: NSError
        switch afError {
        case .responseValidationFailed(reason: let reason):
            switch reason {
            case .unacceptableStatusCode(code: let code):
                nsError = NSError(code: code, reason: "Unacceptable status code.")
            case .customValidationFailed(error: let error):
                nsError = error as NSError
            default:
                nsError = afError as NSError
            }
        case .sessionInvalidated(error: let error):
            if let error {
                nsError = error as NSError
            } else {
                nsError = NSError(code: -1, reason: "Session invalidated.")
            }
        case .sessionTaskFailed(error: let error):
            nsError = error as NSError
        case .serverTrustEvaluationFailed(reason: let serverTrustFailureReason):
            switch serverTrustFailureReason {
            case .customEvaluationFailed(error: let error):
                nsError = error as NSError
            default:
                nsError = NSError(code: -4, reason: "Server trust evaluation failed.")
            }
        case .responseSerializationFailed(reason: let responseSerializationFailureReason):
            switch responseSerializationFailureReason {
            case .jsonSerializationFailed(error: let error):
                nsError = error as NSError
            case .decodingFailed(error: let error):
                nsError = error as NSError
            case .customSerializationFailed(error: let error):
                nsError = error as NSError
            default:
                nsError = afError as NSError
            }
        case .explicitlyCancelled:
            nsError = NSError.cancelledError(reason: "Request explicitly cancelled.")
        case .requestRetryFailed(retryError: let retryError, originalError: let originalError):
            if let afError = retryError as? AFError {
                return self.initFrom(afError: afError)
            } else {
                nsError = originalError as NSError
            }
        default:
            nsError = afError as NSError
        }
        return nsError
    }
}

extension Task where Success == Never, Failure == Never {
    /// Проверка отменённости.
    static func checkIfCancelled() throws(CancellationError) {
        do {
            try self.checkCancellation()
        } catch let cancellationError as CancellationError {
            throw cancellationError
        } catch {
            throw _Concurrency.CancellationError()
        }
    }
}
