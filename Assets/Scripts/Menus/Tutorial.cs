using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using UnityEngine.Video;

public class Tutorial : MonoBehaviour
{
    [SerializeField]
    private Image m_image;

    [SerializeField]
    private Text m_text;

    [SerializeField]
    private bool m_playerIsInArea;

    [SerializeField]
    private Animation m_animation;

    [SerializeField]
    private GameObject m_player;

    [SerializeField]
    private InputAction m_unpause;

    private PlayerInput m_input;

    private void Awake()
    {
        m_text.gameObject.SetActive(false);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            m_player = other.gameObject;

            ShowTutorial();

            m_player.GetComponent<CharacterControllerScript>().enabled = false;
            m_player.GetComponent<WeaponController>().enabled = false;
            m_player.GetComponentInChildren<Animator>().enabled = false;

            m_input = other.GetComponent<PlayerInput>();

            m_playerIsInArea = true;

            m_unpause = m_input.actions["CloseTutorial"];
        }
    }

    IEnumerator WaitForHalfASecondCourotine()
    {
        yield return new WaitForSeconds(0.5f);
    }

    private void Update()
    {
        if (m_player == null)
        {
            m_player = GameObject.FindGameObjectWithTag("Player");
        }

        if (m_playerIsInArea)
        {
            if (m_unpause.triggered)
            {
                HideTutorial();

                m_player.GetComponent<CharacterControllerScript>().enabled = true;
                m_player.GetComponent<WeaponController>().enabled = true;
                m_player.GetComponentInChildren<Animator>().enabled = true;

                m_playerIsInArea = true;

            }
        }
    }

    public void ShowTutorial()
    {
        m_text.gameObject.SetActive(true);
        gameObject.SetActive(true);
        m_animation.Play("TutorialShow");
    }

    public void HideTutorial()
    {
        m_text.gameObject.SetActive(false);
        m_animation.Play("TutorialHide");
        gameObject.SetActive(false);
    }

}
