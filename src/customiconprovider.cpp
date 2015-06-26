/* Slightly adapted from:
 * http://sailfishdev.tumblr.com/post/87464226712/iconbutton-how-to-use-own-icons-with-highlight
 */

#include "customiconprovider.h"

#include <QtGui/QPainter>
#include <QtGui/QColor>

QPixmap CustomIconProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    QStringList parts = id.split('?');

    QString sourcePath = ":/qml/images/" + parts.at(0) + ".png";

    QPixmap sourceIcon(sourcePath);

    if (size)
        *size = sourceIcon.size();

    if (parts.length() > 1) {
        if (QColor::isValidColor(parts.at(1))) {
            QPainter painter(&sourceIcon);
            painter.setCompositionMode(QPainter::CompositionMode_SourceIn);
            painter.fillRect(sourceIcon.rect(), parts.at(1));
            painter.end();
        }
    }

    if (requestedSize.width() > 0 && requestedSize.height() > 0) {
        return sourceIcon.scaled(requestedSize);
    }
    return sourceIcon;
}
