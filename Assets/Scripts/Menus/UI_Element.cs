using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UI_Element : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    [SerializeField]
    private Image m_image;

    private bool m_active;

    [SerializeField]
    private GameManagerScript m_gameManager;

    private void Update()
    {
        if (m_gameManager == null)
        {
            m_gameManager = GameObject.Find("GameManager").GetComponent<GameManagerScript>();
        }

        if (m_active)
        {
            m_image.gameObject.SetActive(true);
        }
        else
        {
            m_image.gameObject.SetActive(false);
        }
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        m_active = true;
        m_gameManager.OnHoverPlaySound();
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        m_active = false;
    }
}
