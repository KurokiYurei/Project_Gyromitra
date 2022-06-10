using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UI_Element : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    [SerializeField]
    private Image m_image;

    private bool m_active;

    private void Update()
    {
        if (m_active)
        {
            m_image.gameObject.SetActive(true);
        } else
        {
            m_image.gameObject.SetActive(false);
        }
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        m_active = true;
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        m_active = false;
    }
}
